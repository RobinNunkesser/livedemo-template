import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/mensaplan/mensaplan_screen.dart';
import 'features/stundenplan/stundenplan_screen.dart';
import 'features/dozentenliste/dozentenliste_screen.dart';
import 'features/uebungsaufgaben/uebungsaufgaben_screen.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CampusFlow',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    StundenplanScreen(),
    MensaplanScreen(),
    DozentenlisteScreen(),
    UebungsaufgabenScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.schedule),
            label: 'Stundenplan',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant),
            label: 'Mensaplan',
          ),
          NavigationDestination(icon: Icon(Icons.people), label: 'Dozenten'),
          NavigationDestination(
            icon: Icon(Icons.assignment),
            label: 'Aufgaben',
          ),
        ],
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
    );
  }
}
