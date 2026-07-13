import 'dart:async';

import 'package:get/get.dart';
import 'package:open_mower_app/io/mqtt_connection.dart';
import 'package:open_mower_app/models/map_model.dart';
import 'package:open_mower_app/models/map_overlay_model.dart';
import 'package:open_mower_app/models/robot_state.dart';

class RobotStateController extends GetxController {
  final robotState = RobotState().obs;

  final map = MapModel().obs;
  final mapOverlay = MapOverlayModel().obs;

  var availableActions = <String>{}.obs;

  Timer? _heartbeatCheckTimer;

  @override
  void onInit() {
    super.onInit();
    _heartbeatCheckTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (robotState.value.isConnected && !robotState.value.heartbeatOk) {
        robotState.refresh();
      }
      if (robotState.value.isConnected && robotState.value.lastHeartbeat != null &&
          DateTime.now().difference(robotState.value.lastHeartbeat!) > const Duration(seconds: 5)) {
        // MQTT client thinks it's connected but no data flows (WiFi power-save).
        // Disconnect so the periodic tryConnect() in main.dart will reconnect.
        Get.find<MqttConnection>().client.disconnect();
      }
    });
  }

  @override
  void onClose() {
    _heartbeatCheckTimer?.cancel();
    super.onClose();
  }

  void start() {
    robotState.value.isRunning = true;
    robotState.refresh();
  }

  void stop() {
    robotState.value.isRunning = false;
    robotState.refresh();
  }

  void setConnected(bool isConnected) {

    if(!isConnected) {
      // disable all buttons if not connected
      availableActions.clear();
      robotState.value.lastHeartbeat = null;
    }

    robotState.value.isConnected = isConnected;
    robotState.refresh();
  }

  bool hasAction(String action) {
    return availableActions.contains(action);
  }
  bool hasAnyAction(List<String> actions) {
    for(final a in actions) {
      if(availableActions.contains(a)) {
        return true;
      }
    }
    return false;
  }

}
