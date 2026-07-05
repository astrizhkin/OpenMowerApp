import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class AccessPoint {
  final String ssid;
  final int strength;
  final int frequency;
  final List<String> security;
  final String bssid;

  AccessPoint({
    required this.ssid,
    required this.strength,
    required this.frequency,
    required this.security,
    required this.bssid,
  });

  factory AccessPoint.fromJson(Map<String, dynamic> json) {
    return AccessPoint(
      ssid: json['ssid'] as String,
      strength: json['strength'] as int,
      frequency: json['frequency'] as int,
      security: List<String>.from(json['security'] as List),
      bssid: json['bssid'] as String,
    );
  }
}

class Connection {
  final String name;
  final String uuid;
  final String type;
  final String mode;
  final bool autoconnect;
  final String state;

  Connection({
    required this.name,
    required this.uuid,
    required this.type,
    required this.mode,
    required this.autoconnect,
    required this.state,
  });

  bool get isActive => state == 'activated';
  bool get isAp => mode == 'ap';
  bool get isInfrastructure => mode != 'ap';

  factory Connection.fromJson(Map<String, dynamic> json) {
    return Connection(
      name: json['name'] as String,
      uuid: json['uuid'] as String,
      type: json['type'] as String,
      mode: json['mode'] as String? ?? 'infrastructure',
      autoconnect: json['autoconnect'] as bool? ?? false,
      state: json['state'] as String? ?? 'disconnected',
    );
  }
}

class WifiController extends GetxController {
  final RxList<AccessPoint> scanResults = <AccessPoint>[].obs;
  final RxList<Connection> connections = <Connection>[].obs;
  final Rxn<String> activeSsid = Rxn<String>();

  final RxBool scanning = false.obs;
  final RxBool loading = false.obs;
  final RxString error = ''.obs;

  static const Duration _timeout = Duration(seconds: 10);

  String get baseUrl {
    if (kIsWeb && kReleaseMode) {
      return '${Uri.base.origin}/netman';
    }
    final hostname = GetStorage().read('mqtt_hostname') ?? '127.0.0.1';
    return 'http://$hostname/netman';
  }

  List<Connection> get infrastructureConnections =>
      connections.where((c) => c.isInfrastructure).toList();
  List<Connection> get apConnections =>
      connections.where((c) => c.isAp).toList();
  Connection? get activeConnection =>
      connections.where((c) => c.isActive).toList().firstOrNull;

  @override
  void onInit() {
    super.onInit();
    _loadAll();
  }

  void _loadAll() {
    loadConnections();
  }

  Future<void> scan() async {
    scanning.value = true;
    error.value = '';

    try {
      final response =
          await http.get(Uri.parse('$baseUrl/scan')).timeout(_timeout);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        scanResults.value =
            data.map((e) => AccessPoint.fromJson(e as Map<String, dynamic>)).toList();
      } else {
        error.value = 'Scan failed: ${response.statusCode}';
      }
    } catch (e) {
      error.value = 'Scan error: $e';
    } finally {
      scanning.value = false;
    }
  }

  Future<void> loadConnections() async {
    loading.value = true;
    error.value = '';

    try {
      final response =
          await http.get(Uri.parse('$baseUrl/connections')).timeout(_timeout);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> raw = data['connections'] as List<dynamic>;
        connections.value =
            raw.map((e) => Connection.fromJson(e as Map<String, dynamic>)).toList();
        activeSsid.value = activeConnection?.name;
      } else {
        error.value = 'Failed to load connections: ${response.statusCode}';
      }
    } catch (e) {
      error.value = 'Connection error: $e';
    } finally {
      loading.value = false;
    }
  }

  Future<void> connect(String ssid, [String? password]) async {
    error.value = '';

    try {
      final body = <String, dynamic>{'ssid': ssid};
      if (password != null && password.isNotEmpty) {
        body['password'] = password;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/connect'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(_timeout);

      if (response.statusCode != 200) {
        error.value = 'Connect failed: ${response.body}';
      } else {
        _loadAll();
      }
    } catch (e) {
      error.value = 'Connect error: $e';
    }
  }

  Future<void> activate(String name) async {
    error.value = '';

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/activate/$name'),
      ).timeout(_timeout);

      if (response.statusCode != 200) {
        error.value = 'Activate failed: ${response.body}';
      } else {
        _loadAll();
      }
    } catch (e) {
      error.value = 'Activate error: $e';
    }
  }

  Future<void> toggleAutoconnect(Connection conn, bool value) async {
    error.value = '';

    try {
      final body = <String, dynamic>{'autoconnect': value};
      if (!conn.isAp) {
        body['autoconnect-priority'] = 100;
      }

      final response = await http.patch(
        Uri.parse('$baseUrl/connections/${Uri.encodeComponent(conn.name)}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(_timeout);

      if (response.statusCode != 200) {
        error.value = 'Toggle autoconnect failed: ${response.body}';
      } else {
        _loadAll();
      }
    } catch (e) {
      error.value = 'Toggle autoconnect error: $e';
    }
  }

  Future<void> removeConnection(String name) async {
    error.value = '';

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/connections/${Uri.encodeComponent(name)}'),
      ).timeout(_timeout);

      if (response.statusCode != 200) {
        error.value = 'Remove failed: ${response.body}';
      } else {
        _loadAll();
      }
    } catch (e) {
      error.value = 'Remove error: $e';
    }
  }
}
