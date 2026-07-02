import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:niku/namespace.dart' as n;
import 'package:open_mower_app/controllers/mower_settings_controller.dart';

class MowerSettings extends GetView<MowerSettingsController> {
  const MowerSettings({super.key});

  @override
  Widget build(BuildContext context) {
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
                min: 0.0,
                max: 1.0,
                divisions: 20,
                onChanged: controller.updateMowerPower,
              ),
            ),
          ])..mb = 8,
          n.Row([
            n.Text("Sensor Behavior"),
            Expanded(child: Container()),
            Obx(() => DropdownButton<int>(
              value: controller.sensorBehavior.value,
              items: const [
                DropdownMenuItem(value: 0, child: Text("Ignore")),
                DropdownMenuItem(value: 1, child: Text("Stop")),
                // DropdownMenuItem(value: 2, child: Text("Avoid")),
              ],
              onChanged: (v) => controller.updateSensorBehavior(v!),
            )),
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
    ])
      ..p = 16
      ..fullSize;
  }
}
