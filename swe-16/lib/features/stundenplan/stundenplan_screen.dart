import 'package:flutter/material.dart';

class StundenplanScreen extends StatelessWidget {
  const StundenplanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stundenplan')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.schedule, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Stundenplan',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Kommt in Sprint 2', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
