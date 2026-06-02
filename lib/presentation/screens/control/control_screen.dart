import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/robot_provider.dart';
import 'package:flutter_mjpeg/flutter_mjpeg.dart';

class ControlScreen extends StatefulWidget {
  const ControlScreen({super.key});

  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> {
  @override
  Widget build(BuildContext context) {
    final robot = Provider.of<RobotProvider>(context);
    final theme = Theme.of(context);

    return SafeArea(
      child: Column(
        children: [
          _buildCameraView(context, robot),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(child: _buildMovementControls(robot, theme)),
                          const SizedBox(width: 24),
                          Expanded(child: _buildActionControls(robot, theme)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildServoControls(robot, theme),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraView(BuildContext context, RobotProvider robot) {
    final streamUrl = "http://${robot.ipAddress}:8080/video_feed";
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        children: [
          Container(
            color: Colors.black,
            child: robot.connected
                ? Mjpeg(
                    isLive: true,
                    stream: streamUrl,
                    error: (context, error, stack) => Center(
                      child: Text(
                        "Stream Error: $error",
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  )
                : const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.videocam_off, color: Colors.white24, size: 64),
                        SizedBox(height: 16),
                        Text("VIDEO FEED OFFLINE",
                            style: TextStyle(color: Colors.white54, letterSpacing: 2)),
                      ],
                    ),
                  ),
          ),
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  const Text("LIVE", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovementControls(RobotProvider robot, ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("CLIMBING CONTROLS",
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: theme.colorScheme.primary.withValues(alpha: 0.6), letterSpacing: 1)),
        const SizedBox(height: 24),
        _controlButton(Icons.keyboard_arrow_up, "FORWARD", robot, theme),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _controlButton(Icons.keyboard_arrow_left, "LEFT", robot, theme),
            const SizedBox(width: 12),
            _controlButton(Icons.keyboard_arrow_right, "RIGHT", robot, theme),
          ],
        ),
        const SizedBox(height: 12),
        _controlButton(Icons.keyboard_arrow_down, "BACKWARD", robot, theme),
      ],
    );
  }

  Widget _buildActionControls(RobotProvider robot, ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("SYSTEMS",
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: theme.colorScheme.primary.withValues(alpha: 0.6), letterSpacing: 1)),
        const SizedBox(height: 24),
        _actionItem("DEPLOY ARM", Icons.precision_manufacturing, theme.colorScheme.primary, () => robot.send("ARM_DEPLOY"), robot.connected, theme),
        const SizedBox(height: 12),
        _harvestButton(robot, theme),
        const SizedBox(height: 12),
        _actionItem("RESET", Icons.settings_backup_restore, Colors.orange, () => robot.send("RESET"), robot.connected, theme),
        const SizedBox(height: 12),
        _actionItem("STOP ALL", Icons.stop_circle, Colors.red, () => robot.send("EMERGENCY_STOP"), robot.connected, theme),
      ],
    );
  }

  Widget _harvestButton(RobotProvider robot, ThemeData theme) {
    final bool active = robot.isHarvesting && robot.connected;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: robot.connected ? () => robot.toggleHarvest() : null,
        icon: Icon(active ? Icons.pause : Icons.cut, size: 20),
        label: Text(active ? "STOP HARVEST" : "HARVEST ENGINE"),
        style: ElevatedButton.styleFrom(
          backgroundColor: active ? Colors.green : theme.colorScheme.primary.withValues(alpha: 0.1),
          foregroundColor: active ? Colors.white : theme.colorScheme.primary,
          padding: const EdgeInsets.symmetric(vertical: 20),
          side: BorderSide(color: active ? Colors.green : theme.colorScheme.primary.withValues(alpha: 0.3)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: active ? 4 : 0,
        ),
      ),
    );
  }

  Widget _buildServoControls(RobotProvider robot, ThemeData theme) {
    return Column(
      children: [
        Text("SERVO ORIENTATION",
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: theme.colorScheme.primary.withValues(alpha: 0.6), letterSpacing: 1.5)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _servoBtn("LEFT", Icons.rotate_left, 'SERVO_LEFT', robot, theme)),
            const SizedBox(width: 8),
            Expanded(child: _servoBtn("CENTER", Icons.filter_tilt_shift, 'SERVO_CENTER', robot, theme)),
            const SizedBox(width: 8),
            Expanded(child: _servoBtn("RIGHT", Icons.rotate_right, 'SERVO_RIGHT', robot, theme)),
          ],
        ),
      ],
    );
  }

  Widget _controlButton(IconData icon, String command, RobotProvider robot, ThemeData theme) {
    bool enabled = robot.connected;
    return GestureDetector(
      onTapDown: enabled ? (_) => robot.send(command) : null,
      onTapUp: enabled ? (_) => robot.send("STOP") : null,
      onTapCancel: enabled ? () => robot.send("STOP") : null,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          border: Border.all(color: enabled ? theme.colorScheme.primary.withValues(alpha: 0.2) : Colors.black12, width: 2),
          borderRadius: BorderRadius.circular(20),
          color: enabled ? theme.colorScheme.primary.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.02),
        ),
        child: Icon(icon, color: enabled ? theme.colorScheme.primary : Colors.black12, size: 36),
      ),
    );
  }

  Widget _actionItem(String label, IconData icon, Color color, VoidCallback onPressed, bool enabled, ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: enabled ? onPressed : null,
        icon: Icon(icon, size: 20),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withValues(alpha: 0.08),
          foregroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 20),
          side: BorderSide(color: color.withValues(alpha: 0.2)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _servoBtn(String label, IconData icon, String command, RobotProvider robot, ThemeData theme) {
    bool enabled = robot.connected;
    return GestureDetector(
      onTap: enabled ? () => robot.send(command) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: enabled ? theme.colorScheme.primary.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.02),
          border: Border.all(color: enabled ? theme.colorScheme.primary.withValues(alpha: 0.2) : Colors.black12),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: enabled ? theme.colorScheme.primary : Colors.black12, size: 28),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: enabled ? theme.colorScheme.primary : Colors.black12, letterSpacing: 1)),
          ],
        ),
      ),
    );
  }
}
