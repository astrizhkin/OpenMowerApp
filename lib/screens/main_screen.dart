import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:niku/namespace.dart' as n;
import 'package:open_mower_app/controllers/mower_settings_controller.dart';
import 'package:open_mower_app/controllers/remote_controller.dart';
import 'package:open_mower_app/screens/dashboard.dart';
import 'package:open_mower_app/screens/engineering.dart';
import 'package:open_mower_app/screens/mower_settings.dart';
import 'package:open_mower_app/screens/sensor_values.dart';
import 'package:open_mower_app/screens/settings.dart';
import 'package:open_mower_app/views/logo_widget.dart';
import 'package:open_mower_app/views/logo_widget_drawer.dart';

class MainScreen extends StatefulWidget {
  MainScreen({super.key});

  final widgetList = <Widget>[
    Dashboard(),
    const SensorValues(),
    MowerSettings(),
    const Settings(),
    Engineering(),
  ];

  @override
  State<StatefulWidget> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  int _index = 0;
  final MowerSettingsController _mowerSettings = Get.find();
  final RemoteController _remoteControl = Get.find();
  late StreamSubscription _engineeringSub;

  @override
  void initState() {
    super.initState();
    _engineeringSub = _mowerSettings.engineeringUnlocked.stream.listen((_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _engineeringSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const LogoWidget(size: 200),
          titleSpacing: 0,
          elevation: 10,
          shadowColor: Colors.black,
        ),
        drawer: Drawer(
          // Add a ListView to the drawer. This ensures the user can scroll
          // through the options in the drawer if there isn't enough vertical
          // space to fit everything.
          child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: buildDrawerList(),
          ),
        ),
        body: widget.widgetList[_index]
    );
  }

  void _setIndex(int index) {
    Get.back();
    setState(() {
      _index = index;
    });
  }

  List<Widget> buildDrawerList() {
    final drawerList = <Widget>[
      const DrawerHeader(
        decoration: BoxDecoration(
          color: Colors.deepOrange,
        ),
        child: Padding(
            padding: EdgeInsets.all(24),
            child: FittedBox(
                child: LogoWidgetDrawer(size: 0.1))),
      ),
      ListTile(
        leading: n.Icon(Icons.speed),
        title: const Text('Dashboard'),
        onTap: () => _setIndex(0),
      ),
      ListTile(
        leading: n.Icon(Icons.line_axis),
        title: const Text('Sensor Values'),
        onTap: () => _setIndex(1),
      ),
      ListTile(
        leading: n.Icon(Icons.tune),
        title: const Text('Mower Settings'),
        onTap: () {
          _mowerSettings.loadFromServer();
          _setIndex(2);
        },
      ),
    ];

    if(!kReleaseMode || !kIsWeb || _mowerSettings.engineeringUnlocked.value) {
      // show the settings screen on debug versions and on native versions
      drawerList.add(ListTile(
        leading: n.Icon(Icons.settings),
        title: const Text('MQTT Settings'),
        onTap: () => _setIndex(3),
      ));
    }


    if (_mowerSettings.engineeringUnlocked.value) {
      drawerList.add(ListTile(
        leading: n.Icon(Icons.build),
        title: const Text('Engineering'),
        onTap: () => _setIndex(4),
      ));
    }

    return drawerList;
  }

}
