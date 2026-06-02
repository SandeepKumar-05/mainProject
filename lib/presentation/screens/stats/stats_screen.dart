import 'package:flutter/material.dart';
import '../../widgets/glass_card.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("PERFORMANCE ANALYTICS", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white38, letterSpacing: 1.2)),
            const SizedBox(height: 8),
            const Text("Operational Insights", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            _buildPrimaryStat(context),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _buildMiniStat("Efficiency", "94%", Icons.speed, Colors.greenAccent)),
                const SizedBox(width: 16),
                Expanded(child: _buildMiniStat("Uptime", "128h", Icons.timer, Colors.blueAccent)),
              ],
            ),
            const SizedBox(height: 32),
            const Text("Harvesting History", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildHistoryChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryStat(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total Harvested", style: TextStyle(color: Colors.white54)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                child: const Text("+12% vs last week", style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text("1,248", style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900)),
          const Text("Coconuts collected this season", style: TextStyle(fontSize: 12, color: Colors.white38)),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, IconData icon, Color color) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 12),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.white54)),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildHistoryChart() {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _chartBar("M", 0.4),
              _chartBar("T", 0.7),
              _chartBar("W", 0.9),
              _chartBar("T", 0.6),
              _chartBar("F", 0.8),
              _chartBar("S", 0.3),
              _chartBar("S", 0.2),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chartBar(String day, double percent) {
    return Column(
      children: [
        Container(
          width: 20,
          height: 100 * percent,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Colors.green.withValues(alpha: 0.5), Colors.greenAccent],
            ),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 8),
        Text(day, style: const TextStyle(fontSize: 10, color: Colors.white38)),
      ],
    );
  }
}
