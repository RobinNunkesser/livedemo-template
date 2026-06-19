import 'package:flutter/material.dart';

class DozentenlisteScreen extends StatelessWidget {
  const DozentenlisteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dozentenliste')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Dozentenliste',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Kommt in Sprint 3', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
