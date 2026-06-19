import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'features/dozentenliste/dozentenliste_screen.dart';
import 'features/mensaplan/mensaplan_screen.dart';
import 'features/stundenplan/stundenplan_screen.dart';
import 'features/uebungsaufgaben/uebungsaufgaben_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialisiert deutsche Datumsformatierung (für Mensaplan-Header)
  await initializeDateFormatting('de_DE', null);
  runApp(
    const ProviderScope(
      child: CampusFlowApp(),
    ),
  );
}

class CampusFlowApp extends StatelessWidget {
  const CampusFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CampusFlow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1565C0), // TH-Blau
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        // Sichtbare Fokus-Indikatoren für Accessibility (WCAG 2.1 AA)
        focusColor: const Color(0xFF1565C0).withAlpha(50),
      ),
      home: const _MainNavigationScaffold(),
    );
  }
}

class _MainNavigationScaffold extends StatefulWidget {
  const _MainNavigationScaffold();

  @override
  State<_MainNavigationScaffold> createState() =>
      _MainNavigationScaffoldState();
}

class _MainNavigationScaffoldState extends State<_MainNavigationScaffold> {
  // Startet mit Stundenplan (laut UI-Architektur.md: "Die App kann direkt im
  // Bereich Stundenplan starten")
  int _currentIndex = 0;

  static const _screens = [
    StundenplanScreen(),
    MensaplanScreen(),
    UebungsaufgabenScreen(),
    DozentenlisteScreen(),
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
        onDestinationSelected: (index) =>
            setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today),
            label: 'Stundenplan',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu_outlined),
            selectedIcon: Icon(Icons.restaurant_menu),
            label: 'Mensaplan',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment),
            label: 'Aufgaben',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Dozenten',
          ),
        ],
      ),
    );
  }
}
