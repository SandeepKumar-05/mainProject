import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/robot_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _ipController;
  late TextEditingController _portController;

  @override
  void initState() {
    super.initState();
    final robot = Provider.of<RobotProvider>(context, listen: false);
    _ipController = TextEditingController(text: robot.ipAddress);
    _portController = TextEditingController(text: robot.port);
  }

  @override
  void dispose() {
    _ipController.dispose();
    _portController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final robot = Provider.of<RobotProvider>(context);
    final theme = Theme.of(context);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text("SYSTEM CONFIGURATION",
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: theme.colorScheme.primary.withValues(alpha: 0.6),
                  letterSpacing: 1.2)),
          const SizedBox(height: 8),
          const Text("Settings",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.black)),
          const SizedBox(height: 32),
          
          _buildSectionHeader(context, "Network Connection"),
          _buildNetworkCard(robot, theme),
          const SizedBox(height: 24),

          _buildSectionHeader(context, "Connection Help"),
          _buildTipsCard(theme),
          const SizedBox(height: 32),

          _buildSectionHeader(context, "Robot Calibration"),
          _buildSimpleSetting(Icons.height, "Climbing Limit", "25m", theme),
          _buildSimpleSetting(Icons.balance, "Clamp Pressure", "85%", theme),
          const SizedBox(height: 32),

          _buildSectionHeader(context, "System Info"),
          Center(
            child: Opacity(
              opacity: 0.5,
              child: Column(
                children: [
                  const Text("Cocobot OS v2.1.0-stable", style: TextStyle(fontSize: 12, color: Colors.black)),
                  const SizedBox(height: 4),
                  Text("Firmware: v4.5.2 (Latest)",
                      style: TextStyle(fontSize: 10, color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 4),
      child: Text(title,
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary)),
    );
  }

  Widget _buildNetworkCard(RobotProvider robot, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        children: [
          _buildSettingField(Icons.wifi, "IP Address", _ipController, theme),
          const Divider(height: 32, thickness: 0.5),
          _buildSettingField(Icons.lan, "Port", _portController, theme),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: robot.isConnecting
                  ? null
                  : () {
                      robot.updateSettings(_ipController.text.trim(), _portController.text.trim());
                      robot.connected ? robot.disconnect() : robot.connect();
                    },
              icon: robot.isConnecting
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Icon(robot.connected ? Icons.link_off : Icons.link),
              label: Text(
                robot.isConnecting ? "CONNECTING..." : robot.connected ? "DISCONNECT" : "CONNECT TO PI",
                style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: robot.connected ? Colors.red : theme.colorScheme.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
          if (robot.errorMessage.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(robot.errorMessage, style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
          ],
        ],
      ),
    );
  }

  Widget _buildSettingField(IconData icon, String label, TextEditingController controller, ThemeData theme) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: theme.colorScheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: theme.colorScheme.primary, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: Colors.black45, fontWeight: FontWeight.bold)),
              TextField(
                controller: controller,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 4)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTipsCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: theme.colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text("Connectivity Tips", style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            "• Connect phone and Pi to the same Wi-Fi\n"
            "• Ensure server.py is running on the Pi\n"
            "• Default port is usually 8765",
            style: TextStyle(fontSize: 13, color: Colors.black54, height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleSetting(IconData icon, String title, String value, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.black38, size: 20),
          const SizedBox(width: 16),
          Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87))),
          Text(value, style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}
