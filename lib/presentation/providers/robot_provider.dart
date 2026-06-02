import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

enum RobotConnectionState { disconnected, connecting, connected, error }

class RobotProvider extends ChangeNotifier {
  WebSocketChannel? _channel;
  Timer? _mockTimer;

  RobotConnectionState connectionStatus = RobotConnectionState.disconnected;
  String errorMessage = '';
  bool isHarvesting = false;

  bool get connected => connectionStatus == RobotConnectionState.connected;
  bool get isConnecting => connectionStatus == RobotConnectionState.connecting;

  int battery = 0;
  String ipAddress = '192.168.1.100'; // Default IP
  String port = '8765';

  // Telemetry
  double altitude = 0.0;
  double temperature = 0.0;
  int coconutsHarvested = 0;

  // Detection Stats
  int greenCoconuts = 0;
  int dryCoconuts = 0;
  int tenderCoconuts = 0;

  /// 🔌 CONNECT TO RASPBERRY PI
  void connect() async {
    if (connectionStatus == RobotConnectionState.connecting ||
        connectionStatus == RobotConnectionState.connected) return;

    connectionStatus = RobotConnectionState.connecting;
    errorMessage = '';
    notifyListeners();

    try {
      final uri = Uri.parse('ws://$ipAddress:$port');
      _channel = WebSocketChannel.connect(uri);

      await _channel!.ready.timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException('Connection timed out'),
      );

      connectionStatus = RobotConnectionState.connected;
      errorMessage = '';
      _stopMocking();
      notifyListeners();

      _channel!.stream.listen(
        (message) {
          try {
            final data = jsonDecode(message);
            if (data['type'] == 'telemetry') {
              battery = ((data['battery'] ?? battery) as num).toInt();
              altitude = ((data['altitude'] ?? altitude) as num).toDouble();
              temperature = ((data['temperature'] ?? temperature) as num).toDouble();
              coconutsHarvested = ((data['coconuts_harvested'] ?? coconutsHarvested) as num).toInt();

              if (data['detections'] != null) {
                final dets = data['detections'] as Map;
                greenCoconuts = ((dets['green'] ?? 0) as num).toInt();
                dryCoconuts = ((dets['dry'] ?? 0) as num).toInt();
                tenderCoconuts = ((dets['tender'] ?? 0) as num).toInt();
              }
            }
            notifyListeners();
          } catch (e) {
            debugPrint('Parse error: $e');
          }
        },
        onError: (e) {
          _setError('WebSocket error: $e');
        },
        onDone: () {
          if (connectionStatus == RobotConnectionState.connected) {
            _setError('Disconnected from robot');
          }
        },
        cancelOnError: true,
      );
    } catch (e) {
      _setError('Failed to connect: $e');
    }
  }

  void _setError(String message) {
    connectionStatus = RobotConnectionState.error;
    errorMessage = message;
    isHarvesting = false;
    _channel?.sink.close();
    _channel = null;
    notifyListeners();
  }

  /// 🧪 MOCK TELEMETRY
  void startMocking() {
    disconnect();
    connectionStatus = RobotConnectionState.connected;
    battery = 87;
    _mockTimer?.cancel();
    _mockTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      final random = Random();
      battery = max(0, battery - (random.nextInt(5) == 0 ? 1 : 0));
      altitude = 1.0 + random.nextDouble() * 2;
      temperature = 28.0 + random.nextDouble() * 5;
      greenCoconuts += random.nextInt(2);
      notifyListeners();
    });
    notifyListeners();
  }

  void _stopMocking() {
    _mockTimer?.cancel();
    _mockTimer = null;
  }

  /// ❌ DISCONNECT
  void disconnect() {
    connectionStatus = RobotConnectionState.disconnected;
    errorMessage = '';
    isHarvesting = false;
    _stopMocking();
    _channel?.sink.close();
    _channel = null;
    notifyListeners();
  }

  /// 🕹️ TOGGLE HARVESTING
  void toggleHarvest() {
    if (!connected) return;
    
    isHarvesting = !isHarvesting;
    send(isHarvesting ? "MOTOR_ON" : "MOTOR_OFF");
    notifyListeners();
  }

  /// 🎮 SEND COMMAND
  void send(String command) {
    if (_channel != null && connected) {
      try {
        final payload = jsonEncode({"command": command});
        _channel!.sink.add(payload);
        debugPrint('→ CMD: $command');
      } catch (e) {
        _setError('Send failed: $e');
      }
    } else {
      debugPrint('Cannot send "$command" - not connected');
    }
  }

  void updateSettings(String newIp, String newPort) {
    ipAddress = newIp;
    port = newPort;
    notifyListeners();
  }

  @override
  void dispose() {
    _mockTimer?.cancel();
    _channel?.sink.close();
    super.dispose();
  }
}
