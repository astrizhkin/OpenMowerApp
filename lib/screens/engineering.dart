import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:niku/namespace.dart' as n;
import 'package:open_mower_app/controllers/remote_controller.dart';
import 'package:open_mower_app/controllers/robot_state_controller.dart';
import 'package:open_mower_app/views/map_widget.dart';
import 'package:open_mower_app/views/robot_state_widget.dart';

class Engineering extends GetView<RemoteController> {
  Engineering({super.key});

  final RobotStateController robotState = Get.find();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const MapWidget(centerOnRobot: true),
        n.Column([
          Expanded(child: Container()),
          Material(
              elevation: 5,
              child: Obx(() => n.Column([
                    n.Row([
                      n.Button.elevatedIcon(
                          "Stop".n, n.Icon(Icons.stop))
                        ..enable = robotState.hasAction("mower_logic:behavior/abort")
                        ..onPressed = () {
                          if(robotState.hasAction("mower_logic:behavior/abort")) {
                            controller.callAction("mower_logic:behavior/abort");
                          }
                        }
                        ..elevation = 2
                        ..expanded
                        ..p = 16,
                      n.Button.elevatedIcon(
                          "Debug".n, n.Icon(Icons.circle))
                        ..enable = robotState.hasAction("mower_logic:idle/start_debug")
                        ..onPressed = () {
                          controller.callAction("mower_logic:idle/start_debug");
                        }
                        ..elevation = 2
                        ..expanded
                        ..p = 16,
                   ])
                      ..gap = 8
                      ..px = 16
                      ..py = 8,
                  ])..py = 8),
          )
        ]),
        const RobotStateWidget(),
      ],
    );
  }
}
