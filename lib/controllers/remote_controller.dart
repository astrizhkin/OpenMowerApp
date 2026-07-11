import 'dart:async';
import 'dart:convert';

import 'package:bson/bson.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:open_mower_app/controllers/settings_controller.dart';
import 'package:open_mower_app/io/mqtt_connection.dart';
import 'package:open_mower_app/models/joystick_command.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:typed_data/typed_data.dart';

class RemoteController extends GetxController {

  final SettingsController settingsController = Get.find();
  final MqttConnection _mqttConnection = Get.find();

  WebSocketChannel? channel;
  final joystickCommand = const JoystickCommand(0,0).obs;

  // --- Wi-Fi radio keep-alive (power-save workaround) ----------------------
  // On the mower's own access point (no internet) the phone Wi-Fi radio enters
  // 802.11 power-save whenever the uplink goes idle; the Pi AP then fails to
  // deliver buffered downstream frames and MQTT telemetry (robot_state) stalls
  // within 1-2s. A dense uplink stream keeps the radio awake so downstream
  // keeps flowing -- this is exactly why moving the joystick (a frame every
  // 20ms) revives telemetry. We reproduce that here: while the joystick is
  // centered we inject a tiny frame every 40ms so the radio never dozes.
  // During active driving the joystick's own stream already keeps it awake, so
  // we stay silent and never disturb teleop.
  //
  // NOTE: this is a workaround, not a fix. It keeps the radio hot (battery
  // cost) and masks a root cause that really lives on the mower's AP. It also
  // only holds while the browser tab is foreground+visible (background tabs get
  // their timers throttled). The proper fix is on the Pi (hostapd/driver PS
  // buffering).
  static const Duration _radioKeepAlivePeriod = Duration(milliseconds: 40);
  // Deliberately NOT a teleop command: a tiny BSON doc the server can ignore,
  // so it is never interpreted as movement. If the port-9002 server rejects
  // unknown docs (watch for the 9002 socket flapping/reconnecting), switch this
  // to a zero teleop: BsonCodec.serialize({"vx": 0, "vz": 0}).byteList
  static final List<int> _radioKeepAliveBytes =
      BsonCodec.serialize({"ka": 1}).byteList;
  Timer? _radioKeepAliveTimer;

  @override
  void onInit() {
    super.onInit();

    interval(joystickCommand, (callback) => {
      sendMessage(callback.x, callback.z)
    }, time: const Duration(milliseconds: 20));

    // for safety, if joystick command wasnt changed for some time, send a 0
    debounce(joystickCommand, (callback) => {sendMessage(0,0)}
        , time: const Duration(milliseconds: 100));

    // listen on hostname changes, then invalidate the channel
    ever(settingsController.hostname, (callback) => (){
      print("settings changed, resetting websocket");
      channel = null;
    });

    _startRadioKeepAlive();
  }

  @override
  void onClose() {
    _stopRadioKeepAlive();
    super.onClose();
  }

  void _startRadioKeepAlive() {
    _radioKeepAliveTimer?.cancel();
    _radioKeepAliveTimer = Timer.periodic(_radioKeepAlivePeriod, (_) {
      final c = joystickCommand.value;
      // Only when the stick is centered; driving already keeps the radio awake
      // (and we must not interleave non-teleop frames into a live command stream).
      if (c.x != 0 || c.z != 0) return;
      _sendRaw(_radioKeepAliveBytes);
    });
  }

  void _stopRadioKeepAlive() {
    _radioKeepAliveTimer?.cancel();
    _radioKeepAliveTimer = null;
  }

  void _sendRaw(List<int> bytes) {
    if(channel == null || channel?.closeCode != null) {
      // reconnect
      connectWebsocket();
    }
    channel?.sink.add(bytes);
  }

  void connectWebsocket() {
    if(kIsWeb && kReleaseMode) {
      // Release and web, we can just connect to the root of the current URL
      channel = WebSocketChannel.connect(Uri.parse('ws://${Uri.base.host}:9002'));
    } else {
      // Connect according to settings
      channel = WebSocketChannel.connect(Uri.parse('ws://${settingsController.hostname}:9002'));
    }

  }

  void sendMessage(double x, double r) {
    if(channel == null || channel?.closeCode != null) {
      // reconnect
      connectWebsocket();
    }
    if(channel != null) {
      final map = {"vx": x,
        "vz": r};
      final binary = BsonCodec.serialize(map);
      channel?.sink.add(binary.byteList);
    }
  }

  void callAction(String action) {
    _mqttConnection.callAction("action",action);
  }

  void callActionJson(String action, [String? parameters]) {
    Map<String, Object> object = {"action": action};
    if(parameters != null) {
      object["parameters"] = parameters;
    }
    String jsonPayload = jsonEncode(object);
    _mqttConnection.callAction("actionJson",jsonPayload);
  }
}
