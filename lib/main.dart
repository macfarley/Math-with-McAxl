import 'package:flutter/material.dart';
import 'screens/calculator_screen.dart';
import 'screens/graph_screen.dart';
import 'screens/converter_screen.dart';
import 'screens/utility_panel.dart';

void main() {
  runApp(const MathWithMcAxlApp());
}

class MathWithMcAxlApp extends StatelessWidget {
  const MathWithMcAxlApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Math with McAxl',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1976D2),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'monospace',
      ),
      home: const HomeShell(),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  static const List<Widget> _screens = [
    CalculatorScreen(),
    GraphScreen(),
    ConverterScreen(),
    UtilityPanel(),
  ];

  static const List<NavigationDestination> _destinations = [
    NavigationDestination(
      icon: Icon(Icons.calculate_outlined),
      selectedIcon: Icon(Icons.calculate),
      label: 'Calc',
    ),
    NavigationDestination(
      icon: Icon(Icons.show_chart_outlined),
      selectedIcon: Icon(Icons.show_chart),
      label: 'Graph',
    ),
    NavigationDestination(
      icon: Icon(Icons.swap_horiz_outlined),
      selectedIcon: Icon(Icons.swap_horiz),
      label: 'Convert',
    ),
    NavigationDestination(
      icon: Icon(Icons.grid_view_outlined),
      selectedIcon: Icon(Icons.grid_view),
      label: 'Tools',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: _destinations,
      ),
    );
  }
}
