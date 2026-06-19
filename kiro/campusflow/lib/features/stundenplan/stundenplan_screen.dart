import 'package:flutter/material.dart';

/// Stundenplan-Platzhalter-Screen – wird in Sprint 2 vollständig umgesetzt.
class StundenplanScreen extends StatelessWidget {
  const StundenplanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stundenplan'),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Stundenplan',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Kommt in Sprint 2',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
