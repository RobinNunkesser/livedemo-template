import 'package:flutter/material.dart';

class MensaplanScreen extends StatelessWidget {
  const MensaplanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mensaplan')),
      body: const Center(child: Text('Mensaplan wird geladen...')),
    );
  }
}
