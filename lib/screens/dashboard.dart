import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:niku/namespace.dart' as n;
import 'package:open_mower_app/controllers/remote_controller.dart';
import 'package:open_mower_app/controllers/robot_state_controller.dart';
import 'package:open_mower_app/models/joystick_command.dart';
import 'package:open_mower_app/models/map_model.dart';
import 'package:open_mower_app/screens/remote_control.dart';
//import 'package:open_mower_app/views/joystick/lib/flutter_joystick.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:open_mower_app/views/map_widget.dart';
import 'package:open_mower_app/views/robot_state_widget.dart';
import 'dart:async';

import 'package:flutter/material.dart';


class Dashboard extends GetView<RobotStateController> {
  Dashboard({super.key});

  final RemoteController remoteControl = Get.find();

  @override
  Widget build(BuildContext context) {
    return n.Column([
      const RobotStateWidget(),
      n.Stack([
        Obx(() => MapWidget(
            centerOnRobot:
                controller.robotState.value.currentState == "AREA_RECORDING")),
        
      ])
        ..expanded,
      Material(
          elevation: 5, child: Obx(() => getButtonPanel(context, controller)))
    ]);
  }

  Widget getButtonPanel(BuildContext context, RobotStateController controller) {
    final screenSize = MediaQuery.of(context).size;
    final useCompactLayout = screenSize.width <= 480;
    final double buttonPadding = useCompactLayout ? 10 : 16;

    if (controller.robotState.value.currentState != "AREA_RECORDING") {
      return n.Row([
        !controller.hasAction("mower_logic:mowing/pause")
        ? (n.Button.elevatedIcon("Start".n, n.Icon(Icons.play_arrow))
          ..enable = controller.hasAnyAction(["mower_logic:idle/start_mowing","mower_logic:mowing/continue"])
          ..onPressed = () {
            if (controller.hasAction("mower_logic:idle/start_mowing")) {
              //remoteControl.callAction("mower_logic:idle/start_mowing");
              n.showDialog(
                barrierDismissible: false,
                context: context,
                builder: (context) => buildSelectAreasDialog(context));
            } else if (controller.hasAction("mower_logic:mowing/continue")) {
              remoteControl.callAction("mower_logic:mowing/continue");
            } 
          }
          ..expanded
          ..elevation = 2
          ..p = buttonPadding)
        : (n.Button.elevatedIcon("Pause".n, n.Icon(Icons.pause))
          ..enable = controller.hasAction("mower_logic:mowing/pause")
          ..onPressed = () {
            remoteControl.callAction("mower_logic:mowing/pause");
          }
          ..expanded
          ..elevation = 2
          ..p = buttonPadding),

          if (controller.hasAction("mower_logic:mowing/skip_area")) 
              n.Button.elevatedIcon((useCompactLayout ? "Next" : "Skip area").n, n.Icon(Icons.route))
              ..onPressed = () {
                remoteControl.callAction("mower_logic:mowing/skip_area");
              }
              ..style = n.ButtonStyle(backgroundColor: Colors.orangeAccent)
              ..elevation = 2
              ..p = buttonPadding,

          n.Button.elevatedIcon("Stop".n, n.Icon(Icons.home))
          ..enable = controller.hasAnyAction([
                  "mower_logic:mowing/abort_mowing",
                  "mower_logic:docking/abort_docking",
                  "mower_logic:undocking/abort_undocking",
                  "mower_logic:behavior/abort"
                ])
          ..onPressed = () {
            if (controller.hasAction("mower_logic:mowing/abort_mowing")) {
              remoteControl.callAction("mower_logic:mowing/abort_mowing");
            } else if (controller.hasAction("mower_logic:docking/abort_docking")) {
              remoteControl.callAction("mower_logic:docking/abort_docking");
            } else if (controller.hasAction("mower_logic:undocking/abort_undocking")) {
              remoteControl.callAction("mower_logic:undocking/abort_undocking");
            } else if (controller.hasAction("mower_logic:behavior/abort")){
              remoteControl.callAction("mower_logic:behavior/abort");
            }
          }
          ..elevation = 2
          ..p = buttonPadding,
        n.Button.elevatedIcon(
            "Record".n, n.Icon(Icons.fiber_manual_record))
          ..enable = controller.hasAction("mower_logic:idle/start_area_recording")
          ..onPressed = () {
              remoteControl.callAction("mower_logic:idle/start_area_recording");
          }
          ..elevation = 2
          ..p = buttonPadding,
      ])
        ..gap = 8
        ..p = buttonPadding;
    } else {
      return
          n.Row([
          n.Column([
            n.Row([
              !controller.hasAction("mower_logic:area_recording/stop_recording")
                ? (n.Button.elevatedIcon("Record".n, n.Icon(Icons.fiber_manual_record))
                  ..enable = controller.hasAction("mower_logic:area_recording/start_recording")
                  ..onPressed = () {
                      remoteControl.callAction("mower_logic:area_recording/start_recording");
                  }
                  ..expanded
                  ..elevation = 2
                  ..px = 12
                  ..py = 8)
                : (n.Button.elevatedIcon("Stop".n, n.Icon(Icons.fiber_manual_record))
                  ..visible = controller.hasAction("mower_logic:area_recording/stop_recording")
                  ..onPressed = () {
                      remoteControl.callAction("mower_logic:area_recording/stop_recording");
                  }
                  ..style = n.ButtonStyle(backgroundColor: Colors.red)
                  ..expanded
                  ..elevation = 2
                  ..px = 12
                  ..py = 8),
              ])
              ..py = 5,
            n.Row([              
              n.Button.elevatedIcon("Finish".n, n.Icon(Icons.stop),
                  onPressed: () {
                    n.showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (context) => buildSaveAreaDialog());
                  })
                ..enable = controller.hasAnyAction([
                  "mower_logic:area_recording/finish_navigation_area",
                  "mower_logic:area_recording/finish_prohibited_area",
                  "mower_logic:area_recording/finish_mowing_area",
                  "mower_logic:area_recording/finish_discard"
                ])
                ..expanded
                ..elevation = 2
                ..px = 12
                ..py = 8,
            ])
              ..py = 5,
            n.Row([
              n.Button.elevatedIcon("Docking".n, n.Icon(Icons.home))
                ..enable = controller.hasAction("mower_logic:area_recording/record_dock")
                ..onPressed = () {
                    remoteControl.callAction("mower_logic:area_recording/record_dock");
                }
                ..elevation = 2
                ..expanded
                ..px = 12
                ..py = 8,
            ])
              ..py = 5,
            n.Row([              
             n.Button.elevatedIcon("Exit".n, n.Icon(Icons.exit_to_app))
                ..enable = controller.hasAction("mower_logic:area_recording/exit_recording_mode")
                ..onPressed = () {
                  remoteControl.callAction("mower_logic:area_recording/exit_recording_mode");
                }
                ..elevation = 2
                ..expanded
                ..px = 12
                ..py = 8,
            ])
              ..py = 5,
          ])
            ..pl = 16
            ..py = 8
          ..expanded,
          Padding(
              padding: const EdgeInsets.all(24),
              child: Joystick(
                //initialX: 5,
                //initialY: 5,
                mode: JoystickMode.all,
                onStickDragEnd: () {
                  remoteControl.sendMessage(0, 0);
                },
                listener: (details) {
                  remoteControl.joystickCommand.value =
                      JoystickCommand(-details.y * 1.0, -details.x * 1.6);
                },
              )),
        ]);
    }
  }

  Widget buildSaveAreaDialog() {
    return n.Alert.adaptive()
      ..title = "Save Area".n
      ..content = "Save area as navigation, mowing or prohibited area?".n
      ..actions = [
        n.Button("Mowing Area".n)
          // ..enable = robotState
          //     .hasAction("mower_logic:area_recording/finish_mowing_area")
          ..onPressed = () {
            remoteControl
                .callAction("mower_logic:area_recording/finish_mowing_area");
            Get.back();
          }
          ..bold
          ..p = 24,
        n.Button("Navigation Area".n)
          // ..enable = robotState
          //     .hasAction("mower_logic:area_recording/finish_navigation_area")
          ..onPressed = () {
            remoteControl.callAction(
                "mower_logic:area_recording/finish_navigation_area");
            Get.back();
          }
          ..bold
          ..p = 24,
        n.Button("Prohibited Area".n)
          // ..enable = robotState
          //     .hasAction("mower_logic:area_recording/finish_prohibited_area")
          ..onPressed = () {
            remoteControl.callAction(
                "mower_logic:area_recording/finish_prohibited_area");
            Get.back();
          }
          ..bold
          ..p = 24,
        n.Button("Don't Save".n)
          ..onPressed = () {
            remoteControl
                .callAction("mower_logic:area_recording/finish_discard");
            Get.back();
          }
          ..bold
          ..color = Colors.red
          ..p = 24
      ];
  }

  Widget scrollbarIfNecessary(BuildContext context, Widget child) {
    final currentPlatform = Theme.of(context).platform;
    final ScrollController controller = ScrollController();
    switch (currentPlatform) {
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        return child;
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.iOS:
        return Scrollbar(
          controller: controller,
          child: child
        );
    }
  }

  Widget buildSelectAreasDialog(BuildContext context) {
    MapModel mapModel = controller.map.value;
    final Map<String,bool> selectedAreas = {};
    for(final area in mapModel.areas) {
      if (area.area_type == 2) selectedAreas[area.name] = true;
    }
    return StatefulBuilder(builder: (context, setState) {
      return n.Alert()
        ..title = "Select areas".n
        ..content = scrollbarIfNecessary(
            context,
            SingleChildScrollView(
              child: n.Column([
                for (final area in mapModel.areas)
                  if (area.area_type == 2)
                    n.CheckboxListTile(selectedAreas[area.name])
                      ..title = area.name.n
                      ..controlAffinity = ListTileControlAffinity.leading
                      ..onChanged = (value) {
                          setState(() {
                            selectedAreas[area.name] = value ?? false;
                          });
                      },
              ])
            )
          )
        ..actions = [
          n.Button("Start (${selectedAreas.values.where((v) => v).length})".n)
            ..onPressed = () {
              String areasStr = "";
              for(final areaName in selectedAreas.keys){
                if(selectedAreas[areaName] ?? false) {
                  if(areasStr.isNotEmpty){
                    areasStr+=",";
                  }
                  areasStr+=areaName;
                }
              }
              remoteControl.callActionJson("mower_logic:idle/start_mowing",areasStr);
              Get.back();
            }
            ..bold
            ..p = 24,
          n.Button("Cancel".n)
            // ..enable = robotState
            //     .hasAction("mower_logic:area_recording/finish_navigation_area")
            ..onPressed = () {
              //remoteControl.callAction(
              //    "mower_logic:area_recording/finish_navigation_area");
              Get.back();
            }
            ..bold
            ..p = 24,
        ];
    });
  }

}
