import 'package:flutter/material.dart';
import './dashboard/dashboard_screen.dart';
import './control/control_screen.dart';
import './stats/stats_screen.dart';
import './settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const ControlScreen(),
    const StatsScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(
              'https://cdn-icons-png.flaticon.com/512/3522/3522213.png', // Robot icon
              height: 24,
              color: Colors.greenAccent,
              colorBlendMode: BlendMode.srcIn,
            ),
            const SizedBox(width: 12),
            const Text(
              "COCOBOT",
              style: TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05), width: 1)),
        ),
        child: NavigationBar(
          height: 80,
          elevation: 0,
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) => setState(() => _selectedIndex = index),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard, color: Colors.greenAccent),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.videogame_asset_outlined),
              selectedIcon: Icon(Icons.videogame_asset, color: Colors.greenAccent),
              label: 'Control',
            ),
            NavigationDestination(
              icon: Icon(Icons.analytics_outlined),
              selectedIcon: Icon(Icons.analytics, color: Colors.greenAccent),
              label: 'Stats',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings, color: Colors.greenAccent),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
