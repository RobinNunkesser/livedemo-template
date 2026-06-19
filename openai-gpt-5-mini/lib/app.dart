import 'package:flutter/material.dart';
import 'features/mensa/mensa_screen.dart';

class CampusFlowApp extends StatelessWidget {
  const CampusFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CampusFlow MVP',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MainScaffold(),
    );
  }
}

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _index = 0;

  static const _tabs = <Widget>[
    MensaScreen(),
    PlaceholderScreen(title: 'Stundenplan'),
    PlaceholderScreen(title: 'Dozentenliste'),
    PlaceholderScreen(title: 'Übungsaufgaben'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.restaurant_menu), label: 'Mensa'),
          BottomNavigationBarItem(
              icon: Icon(Icons.schedule), label: 'Stundenplan'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Dozenten'),
          BottomNavigationBarItem(icon: Icon(Icons.task), label: 'Aufgaben'),
        ],
      ),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text('$title\nKommt in Sprint 2', textAlign: TextAlign.center),
        ),
      );
}
