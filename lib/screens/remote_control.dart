import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:niku/namespace.dart' as n;
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:get/get.dart';
import 'package:open_mower_app/controllers/remote_controller.dart';
import 'package:open_mower_app/controllers/robot_state_controller.dart';
import 'package:open_mower_app/models/joystick_command.dart';
import 'package:open_mower_app/views/map_widget.dart';
import 'package:open_mower_app/views/robot_state_widget.dart';

class RemoteControl extends GetView<RemoteController> {
  RemoteControl({super.key});

  final RobotStateController robotState = Get.find();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const MapWidget(centerOnRobot: true),
        n.Column([
          Expanded(
              child: Align(
            alignment: const Alignment(0, 0.8),
            child: Joystick(
              mode: JoystickMode.all,
              onStickDragEnd: () {
                controller.sendMessage(0, 0);
              },
              listener: (details) {
                controller.joystickCommand.value =
                    JoystickCommand(-details.y * 1.0, -details.x * 1.6);
              },
            ),
          )),
          Material(
              elevation: 5,
              child: Obx(() => n.Column([
                /*Padding(padding: const EdgeInsets.all(32), child:
                Joystick(
                  mode: JoystickMode.all,
                  onStickDragEnd: () {
                    controller.sendMessage(0, 0);
                  },
                  listener: (details) {
                    controller.joystickCommand.value =
                        JoystickCommand(-details.y * 1.0, -details.x * 1.6);
                  },
                )),*/
                    n.Row([
                      n.Button.elevatedIcon(
                          "Stop".n, n.Icon(Icons.stop))
                        ..enable = robotState.hasAction("mower_logic:behavior/abort")
                        ..onPressed = () {
                          controller.callAction("mower_logic:behavior/abort");
                        }
                        ..elevation = 2
                        ..expanded
                        ..p = 16,
                      n.Button.elevatedIcon(
                          "Manual".n, n.Icon(Icons.circle))
                        ..enable = robotState.hasAction("mower_logic:idle/start_manual")
                        ..onPressed = () {
                          controller.callAction("mower_logic:idle/start_manual");
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
                  ])..py=8)),
        ]),
        const RobotStateWidget(),
      ],
    );
  }
}
