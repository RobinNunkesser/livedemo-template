import 'package:flutter/material.dart';

class UebungsaufgabenScreen extends StatelessWidget {
  const UebungsaufgabenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Übungsaufgaben')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Übungsaufgaben',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Kommt in Sprint 4', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
