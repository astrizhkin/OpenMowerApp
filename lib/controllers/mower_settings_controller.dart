import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:open_mower_app/io/mqtt_connection.dart';

class MowerSettingsController extends GetxController {
  var mowerPower = 1.0.obs;
  var sensorBehavior = 1.obs; // 0=Ignore, 1=Stop, 2=Avoid
  var engineeringUnlocked = false.obs;
  Timer? _debounceTimer;

  final accessCodeController = TextEditingController();

  MqttConnection get _mqttConnection => Get.find<MqttConnection>();

  void loadFromServer() {
    _mqttConnection.requestParameters("mower_logic");
  }

  void updateMowerPower(double value) {
    mowerPower.value = value;
    mowerPower.refresh();
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 200), () {
      _mqttConnection.setParameter("mower_logic", {"mower_power": value});
    });
  }

  void updateSensorBehavior(int value) {
    sensorBehavior.value = value;
    sensorBehavior.refresh();
    _mqttConnection.setParameter("mower_logic", {"sensor_behavior": value});
  }

  void checkAccessCode() {
    if (accessCodeController.text == "developer") {
      engineeringUnlocked.value = true;
      engineeringUnlocked.refresh();
    }
  }

  void applyServerState(Map<String, dynamic> config) {
    if (config.containsKey("mower_power")) {
      mowerPower.value = (config["mower_power"] as num).toDouble();
      mowerPower.refresh();
    }
    if (config.containsKey("sensor_behavior")) {
      sensorBehavior.value = config["sensor_behavior"] as int;
      sensorBehavior.refresh();
    }
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    super.onClose();
  }
}
