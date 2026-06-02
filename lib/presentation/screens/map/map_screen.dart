import 'dart:math';
import 'package:flutter/material.dart';
import '../../widgets/glass_card.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _buildMapHeader(context),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: GlassCard(
                padding: EdgeInsets.zero,
                child: Stack(
                  children: [
                    CustomPaint(
                      painter: FarmMapPainter(),
                      size: Size.infinite,
                    ),
                    Positioned(
                      top: 20,
                      right: 20,
                      child: _buildMapLegend(),
                    ),
                    Positioned(
                      bottom: 20,
                      left: 20,
                      right: 20,
                      child: _buildLocationInfo(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("FARM TOPOGRAPHY", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white38, letterSpacing: 1.2)),
              SizedBox(height: 4),
              Text("Sector A-12", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
          Container(
            decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.2), shape: BoxShape.circle),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.my_location),
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapLegend() {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      borderRadius: 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _legendItem("Robot", Colors.greenAccent),
          const SizedBox(height: 8),
          _legendItem("Climbed", Colors.white54),
          const SizedBox(height: 8),
          _legendItem("Target", Colors.orangeAccent),
        ],
      ),
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildLocationInfo() {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("COORDINATES", style: TextStyle(fontSize: 10, color: Colors.white38)),
              Text("12.9716° N, 77.5946° E", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("ALTITUDE", style: TextStyle(fontSize: 10, color: Colors.white38)),
              Text("920m ASL", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}

class FarmMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Grid lines
    for (double i = 0; i < size.width; i += 40) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 40) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }

    // Stylized trees (circles)
    final random = Random(42);
    final treePaint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 15; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final isClimbed = random.nextBool();
      
      treePaint.color = isClimbed ? Colors.white.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.2);
      canvas.drawCircle(Offset(x, y), 12, treePaint);
      
      treePaint.color = isClimbed ? Colors.white24 : Colors.green.withValues(alpha: 0.5);
      canvas.drawCircle(Offset(x, y), 4, treePaint);
    }

    // Robot Marker
    final robotPos = Offset(size.width * 0.6, size.height * 0.4);
    final robotPaint = Paint()
      ..color = Colors.greenAccent
      ..style = PaintingStyle.fill;
    
    // Pulse effect
    canvas.drawCircle(robotPos, 20, robotPaint..color = Colors.greenAccent.withValues(alpha: 0.2));
    canvas.drawCircle(robotPos, 8, robotPaint..color = Colors.greenAccent);
    
    // Direction line
    canvas.drawLine(
      robotPos,
      Offset(robotPos.dx + 30, robotPos.dy - 30),
      Paint()..color = Colors.greenAccent..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
