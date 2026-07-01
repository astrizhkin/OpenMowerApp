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
              ])..mb = 8,
              Obx(
                () => Slider(
                  value: controller.mowerPower.value,
                  min: 0.0,
                  max: 1.0,
                  divisions: 100,
                  onChanged: controller.updateMowerPower,
                ),
              ),
            ])
              ..m = 16
              ..crossAxisAlignment = CrossAxisAlignment.start,
          )),
      Card(
        elevation: 3,
        child: n.Column([
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
          ]),
        ])
          ..m = 16
          ..crossAxisAlignment = CrossAxisAlignment.start,
      ),
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
          ),
        ])
          ..m = 16
          ..crossAxisAlignment = CrossAxisAlignment.start,
      ),
    ])
      ..p = 16
      ..fullSize;
  }
}
