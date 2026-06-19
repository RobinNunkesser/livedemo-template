/// CampusFlow – App-Einstiegspunkt und Hauptnavigation (SP1-04).
///
/// Vier Tabs: Stundenplan (Platzhalter), Mensaplan (vollständig),
/// Dozentenliste (Platzhalter), Übungsaufgaben (Platzhalter).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/mensaplan/mensaplan_screen.dart';
import 'shared/widgets/placeholder_screen.dart';

void main() {
  runApp(const ProviderScope(child: CampusFlowApp()));
}

class CampusFlowApp extends StatelessWidget {
  const CampusFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CampusFlow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      // Barrierefreiheit: große Touch-Ziele, lesbare Schriftskalierung (A11).
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: MediaQuery.textScalerOf(context),
          ),
          child: child!,
        );
      },
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 1; // Mensaplan als Start (vollständiger Slice in Sprint 1)

  static const _destinations = [
    NavigationDestination(
      icon: Icon(Icons.calendar_today_outlined),
      selectedIcon: Icon(Icons.calendar_today),
      label: 'Stundenplan',
    ),
    NavigationDestination(
      icon: Icon(Icons.restaurant_outlined),
      selectedIcon: Icon(Icons.restaurant),
      label: 'Mensa',
    ),
    NavigationDestination(
      icon: Icon(Icons.people_outline),
      selectedIcon: Icon(Icons.people),
      label: 'Dozenten',
    ),
    NavigationDestination(
      icon: Icon(Icons.task_outlined),
      selectedIcon: Icon(Icons.task),
      label: 'Aufgaben',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          // Stundenplan (Platzhalter, Sprint 2)
          const PlaceholderScreen(title: 'Stundenplan', sprint: 'Sprint 2'),
          // Mensaplan (vollständig, Sprint 1)
          const MensaplanScreen(),
          // Dozentenliste (Platzhalter, Sprint 3)
          const PlaceholderScreen(title: 'Dozentenliste', sprint: 'Sprint 3'),
          // Übungsaufgaben (Platzhalter, Sprint 4)
          const PlaceholderScreen(title: 'Übungsaufgaben', sprint: 'Sprint 4'),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: _destinations,
      ),
    );
  }
}
