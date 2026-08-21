import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:niku/namespace.dart' as n;
import 'package:open_mower_app/controllers/mower_settings_controller.dart';
import 'package:open_mower_app/controllers/remote_controller.dart';

class MowerSettings extends GetView<MowerSettingsController> {
  const MowerSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final RemoteController remoteControl = Get.find();

    return n.Column([
      n.Text("Mower Settings")..mb = 16,
      GetBuilder<MowerSettingsController>(
          builder: (val) => Card(
        elevation: 3,
        child: n.Column([
          n.Row([
            n.Text("Mower Power"),
            Expanded(child: Container()),
            Obx(() => n.Text("${(controller.mowerPower.value * 100).toStringAsFixed(0)}%")),
            Obx(
              () => Slider(
                value: controller.mowerPower.value,
                min: 0.5,
                max: 1.0,
                divisions: 10,
                onChanged: controller.updateMowerPower,
              ),
            ),
          ])..mb = 8,
          n.Row([
            n.Text("Sensor Behavior"),
            Expanded(
              child: Obx(() => DropdownButton<int>(
                value: controller.sensorBehavior.value,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: 0, child: Text("Ignore")),
                  DropdownMenuItem(value: 1, child: Text("Bumper Emergency Only")),
                  DropdownMenuItem(value: 2, child: Text("Bumper Emergency + Ultrasonic Stop")),
                  DropdownMenuItem(value: 3, child: Text("Bumper Emergency + Ultrasonic Avoid")),
                ],
                onChanged: (v) => controller.updateSensorBehavior(v!),
              )),
            ),
          ])..mb = 8,
          n.Row([
            n.Text("Perimeter Dry Run"),
            Expanded(child: Container()),
            Obx(() => Switch(
              value: controller.perimeterDryRun.value,
              onChanged: controller.updatePerimeterDryRun,
            )),
          ])..mb = 8,
          n.Row([
            n.Text("Dock Station at Home"),
            Expanded(child: Container()),
            Obx(() => Switch(
              value: controller.dockStationAtHome.value,
              onChanged: controller.updateDockStationAtHome,
            )),
          ])..mb = 8,
        ])
          ..m = 16
          ..crossAxisAlignment = CrossAxisAlignment.start,
      )),
      Card(
        elevation: 3,
        child: n.Column([
          n.Row([
            n.Text("Access Code"),
            Expanded(child: Container()),
            n.Button.elevatedIcon("Unlock".n, n.Icon(Icons.lock))
              ..onPressed = controller.checkAccessCode
              ..expanded
              ..elevation = 2
              ..p = 8,
          ]),
          n.TextFormField(
            label: "Code".n,
            controller: controller.accessCodeController,
          )..asPassword,
        ])
          ..m = 16
          ..crossAxisAlignment = CrossAxisAlignment.start,
      ),
      Obx(() => controller.serviceUnlocked.value
          ? Card(
              elevation: 3,
              child: n.Column([
                n.Text("Global Actions"),
                n.Row([
                  n.Button.elevatedIcon("New Map".n, n.Icon(Icons.map_outlined))
                    ..onPressed = () {
                      remoteControl.callActionJson("mower_logic/new_map", "new_map");
                    }
                    ..elevation = 2
                    ..expanded
                    ..p = 8,
                ])..mb = 8,
              ])
                ..m = 16
                ..crossAxisAlignment = CrossAxisAlignment.start,
            )
          : Container()),
    ])
      ..p = 16
      ..fullSize;
  }
}
