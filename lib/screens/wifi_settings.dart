import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:niku/namespace.dart' as n;
import 'package:open_mower_app/controllers/wifi_controller.dart';

class WifiSettings extends GetView<WifiController> {
  const WifiSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: n.Column([
        n.Text("WiFi")..mb = 8,
        const _StatusCard(),
        const _ApSection(),
        const _KnownNetworksSection(),
        Card(
          elevation: 3,
          child: n.Column([
            n.Row([
              n.Text("Available Networks"),
              Expanded(child: const SizedBox.shrink()),
              const _ScanButton(),
            ])..mb = 8,
            const _ScanList(),
          ])
            ..m = 16
            ..crossAxisAlignment = CrossAxisAlignment.start,
        ),
        const _ErrorBanner(),
      ])
        ..p = 16,
    );
  }
}

WifiController get _ctrl => Get.find<WifiController>();

class _StatusCard extends ObxWidget {
  const _StatusCard();

  @override
  Widget build() {
    final ctrl = _ctrl;

    if (ctrl.loading.value && ctrl.activeSsid.value == null) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Card(
          elevation: 3,
          child: n.Row([
            const CircularProgressIndicator(strokeWidth: 2),
            n.Text("Loading..."),
          ])
            ..p = 12
            ..gap = 8,
        ),
      );
    }

    final ssid = ctrl.activeSsid.value;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 3,
        child: n.Row([
          n.Icon(ssid != null ? Icons.wifi : Icons.wifi_off)
            ..color = ssid != null ? Colors.green : Colors.grey,
          n.Text(ssid != null ? 'Connected: $ssid' : 'Not connected'),
        ])
          ..p = 12
          ..gap = 8,
      ),
    );
  }
}

class _ApSection extends ObxWidget {
  const _ApSection();

  @override
  Widget build() {
    final apConns = _ctrl.apConnections;
    if (apConns.isEmpty) return const SizedBox.shrink();

    return Card(
      elevation: 3,
      child: n.Column([
        n.Text("Access Points")..mb = 8,
        n.Column(
          apConns.map((conn) => _connectionTile(conn, isAp: true)).toList(),
        ),
      ])
        ..m = 16
        ..crossAxisAlignment = CrossAxisAlignment.start,
    );
  }
}

class _KnownNetworksSection extends ObxWidget {
  const _KnownNetworksSection();

  @override
  Widget build() {
    final infra = _ctrl.infrastructureConnections;
    if (infra.isEmpty) return const SizedBox.shrink();

    return Card(
      elevation: 3,
      child: n.Column([
        n.Row([
          n.Text("Known Networks"),
          Expanded(child: const SizedBox.shrink()),
          IconButton(
            icon: n.Icon(Icons.refresh),
            onPressed: _ctrl.loading.value ? null : _ctrl.loadConnections,
          ),
        ])..mb = 8,
        n.Column(
          infra.map((conn) => _connectionTile(conn, isAp: false)).toList(),
        ),
      ])
        ..m = 16
        ..crossAxisAlignment = CrossAxisAlignment.start,
    );
  }
}

Widget _connectionTile(Connection conn, {required bool isAp}) {
  final isActive = conn.isActive;
  return ListTile(
    leading: Icon(
      isActive ? Icons.wifi : Icons.wifi_protected_setup,
      color: isActive ? Colors.green : Colors.grey,
    ),
    title: n.Text(conn.name),
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: conn.autoconnect,
          side: const BorderSide(color: Colors.grey),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
          onChanged: (val) => _ctrl.toggleAutoconnect(conn, val ?? false),
        ),
        if (!isActive)
          IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: () => _ctrl.activate(conn.name),
            tooltip: 'Connect',
          ),
        if (!isActive && !isAp)
          IconButton(
            icon: const Icon(Icons.delete, size: 20),
            onPressed: () => _confirmRemove(conn.name),
            tooltip: 'Remove',
          ),
      ],
    ),
  );
}

void _confirmRemove(String name) {
  final ctrl = _ctrl;
  Get.dialog(
    AlertDialog(
      title: n.Text("Remove $name?"),
      content: n.Text("This will remove the saved network configuration."),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
        TextButton(
          onPressed: () {
            ctrl.removeConnection(name);
            Get.back();
          },
          child: const Text("Remove"),
        ),
      ],
    ),
  );
}

class _ScanButton extends ObxWidget {
  const _ScanButton();

  @override
  Widget build() {
    final ctrl = _ctrl;
    return IconButton(
      icon: ctrl.scanning.value
          ? const CircularProgressIndicator(strokeWidth: 2)
          : n.Icon(Icons.refresh),
      onPressed: ctrl.scanning.value ? null : ctrl.scan,
    );
  }
}

class _ScanList extends ObxWidget {
  const _ScanList();

  @override
  Widget build() {
    final ctrl = _ctrl;

    if (ctrl.scanResults.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Text("Tap refresh to scan for networks",
            style: TextStyle(color: Colors.grey)),
      );
    }

    return n.Column(
      ctrl.scanResults.map((ap) {
        final isSaved = ctrl.connections.any((c) => c.name == ap.ssid);

        return ListTile(
          leading: n.Icon(Icons.wifi)
            ..color = _signalColor(ap.strength),
          title: n.Text(ap.ssid),
          subtitle: n.Text(
            '${ap.strength} dBm${ap.security.isNotEmpty ? " · ${ap.security.join(", ")}" : ""}',
          ),
          trailing: isSaved
              ? const Text("Saved", style: TextStyle(color: Colors.grey))
              : IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _showConnectDialog(ap.ssid),
                  tooltip: 'Connect',
                ),
        );
      }).toList(),
    );
  }

  Color _signalColor(int strength) {
    if (strength >= 70) return Colors.green;
    if (strength >= 40) return Colors.orange;
    return Colors.red;
  }

  void _showConnectDialog(String ssid) {
    final ctrl = _ctrl;
    final pwCtrl = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: n.Text("Connect to $ssid"),
        content: n.TextFormField(
          label: "Password".n,
          controller: pwCtrl,
        )..asPassword,
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              ctrl.connect(ssid, pwCtrl.text);
              Get.back();
            },
            child: const Text("Connect"),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends ObxWidget {
  const _ErrorBanner();

  @override
  Widget build() {
    final ctrl = _ctrl;
    if (ctrl.error.value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: n.Text(ctrl.error.value)
        ..color = Colors.red,
    );
  }
}
