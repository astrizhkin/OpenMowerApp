import 'package:open_mower_app/models/sensor_state.dart';

class RobotState {
  String name = "Striga";
  double wifiPercent = 0.0;
  double gpsPercent = 0.0;
  double batteryPercent = 0.0;

  String currentState = "Unknown";
  String currentSubState = "";

  bool isRunning = false;
  bool isCharging = false;
  bool isEmergency = false;
  bool isConnected = false;

  double posX = 0, posY = 0, posAccuracy = 0, heading = 0, headingAccuracy = 0;
  bool headingValid = false;
  DateTime? lastHeartbeat;

  bool get heartbeatOk => lastHeartbeat != null &&
      DateTime.now().difference(lastHeartbeat!) < heartbeatTimeout;
}

const Duration heartbeatTimeout = Duration(seconds: 2);
