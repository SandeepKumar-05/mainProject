import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/robot_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _lastError = '';

  @override
  Widget build(BuildContext context) {
    final robot = Provider.of<RobotProvider>(context);
    final theme = Theme.of(context);

    // Show error snack when connection fails
    if (robot.errorMessage.isNotEmpty && robot.errorMessage != _lastError) {
      _lastError = robot.errorMessage;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(robot.errorMessage),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 5),
          ),
        );
      });
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, theme),
            const SizedBox(height: 32),
            _buildMainStatus(context, robot, theme),
            const SizedBox(height: 24),
            _buildDetectionStats(context, robot, theme),
            const SizedBox(height: 24),
            _buildQuickActions(context, robot, theme),
            const SizedBox(height: 32),
            Text(
              "Telemetry Data",
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildTelemetryGrid(robot, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Welcome to Cocobot",
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black54),
        ),
        Text(
          "Management Console",
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildMainStatus(BuildContext context, RobotProvider robot, ThemeData theme) {
    Color cardColor;
    String statusLabel;
    Color statusColor;

    switch (robot.connectionStatus) {
      case RobotConnectionState.connected:
        cardColor = Colors.green;
        statusLabel = 'SYSTEM ARMED';
        statusColor = Colors.green.shade700;
        break;
      case RobotConnectionState.connecting:
        cardColor = Colors.amber;
        statusLabel = 'CONNECTING…';
        statusColor = Colors.amber.shade800;
        break;
      case RobotConnectionState.error:
        cardColor = Colors.red;
        statusLabel = 'CONNECTION ERROR';
        statusColor = Colors.red.shade700;
        break;
      default:
        cardColor = Colors.grey;
        statusLabel = 'SYSTEM DISCONNECTED';
        statusColor = Colors.grey.shade700;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cardColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          _buildStatusIcon(robot.connectionStatus, cardColor),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: statusColor,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.bolt, color: Colors.amber, size: 28),
                    const SizedBox(width: 8),
                    Text(
                      robot.connected ? "${robot.battery}%" : "-%",
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            children: [
              if (!robot.connected && !robot.isConnecting)
                IconButton(
                  onPressed: robot.startMocking,
                  icon: const Icon(Icons.play_arrow, color: Colors.black45),
                  tooltip: "Simulate",
                ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: cardColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: robot.isConnecting
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.amber),
                        ),
                      )
                    : IconButton(
                        onPressed: robot.connected ? robot.disconnect : robot.connect,
                        icon: Icon(
                          robot.connected ? Icons.link_off : Icons.refresh,
                          color: statusColor,
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(RobotConnectionState status, Color color) {
    IconData icon;
    switch (status) {
      case RobotConnectionState.connected:
        icon = Icons.radar;
        break;
      case RobotConnectionState.connecting:
        icon = Icons.sync;
        break;
      case RobotConnectionState.error:
        icon = Icons.wifi_off;
        break;
      default:
        icon = Icons.wifi_off;
    }
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 30),
    );
  }

  Widget _buildDetectionStats(BuildContext context, RobotProvider robot, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Vision Detection",
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _detectionCard("Green", robot.greenCoconuts, Colors.green, theme)),
            const SizedBox(width: 12),
            Expanded(child: _detectionCard("Dry", robot.dryCoconuts, Colors.brown, theme)),
            const SizedBox(width: 12),
            Expanded(child: _detectionCard("Tender", robot.tenderCoconuts, Colors.lightBlue, theme)),
          ],
        ),
      ],
    );
  }

  Widget _detectionCard(String label, int count, Color color, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Text(
            "$count",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: color.withValues(alpha: 0.6), letterSpacing: 1),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, RobotProvider robot, ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: _actionButton(
            context,
            "AUTO HARVEST",
            Icons.play_circle_fill,
            Colors.orange,
            () => robot.send("AUTO"),
            robot.connected,
            theme,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _actionButton(
            context,
            "STOP ALL",
            Icons.stop_circle,
            Colors.red,
            () => robot.send("STOP"),
            robot.connected,
            theme,
          ),
        ),
      ],
    );
  }

  Widget _actionButton(BuildContext context, String label, IconData icon, Color color, VoidCallback? onPressed, bool enabled, ThemeData theme) {
    return ElevatedButton(
      onPressed: enabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withValues(alpha: 0.1),
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: color.withValues(alpha: 0.2), width: 1),
        ),
        elevation: 0,
      ),
      child: Column(
        children: [
          Icon(icon, size: 32),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildTelemetryGrid(RobotProvider robot, ThemeData theme) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _telemetryItem("Altitude", "${robot.altitude.toStringAsFixed(1)}m", Icons.height, Colors.blue, theme),
        _telemetryItem("Temp", "${robot.temperature.toStringAsFixed(1)}°C", Icons.thermostat, Colors.deepOrange, theme),
        _telemetryItem("Signal", "-45dB", Icons.signal_cellular_4_bar, Colors.purple, theme),
        _telemetryItem("Harvested", "${robot.coconutsHarvested}", Icons.shopping_basket, Colors.teal, theme),
      ],
    );
  }

  Widget _telemetryItem(String label, String value, IconData icon, Color color, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.black45, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
