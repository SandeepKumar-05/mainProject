import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:coconut_robot/main.dart';
import 'package:coconut_robot/presentation/providers/robot_provider.dart';

void main() {
  testWidgets('App title smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => RobotProvider(),
        child: const MyApp(),
      ),
    );

    // Verify that our app shows the title "COCOBOT".
    expect(find.text('COCOBOT'), findsOneWidget);
    
    // Check that we have a dashboard icon in the nav bar
    expect(find.byIcon(Icons.dashboard_outlined), findsOneWidget);
  });
}
