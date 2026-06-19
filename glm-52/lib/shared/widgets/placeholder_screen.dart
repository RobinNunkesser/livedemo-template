/// Wiederverwendbarer Platzhalter-Screen für noch nicht implementierte Bereiche.
library;

import 'package:flutter/material.dart';

import '../widgets/empty_state.dart';

class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    super.key,
    required this.title,
    required this.sprint,
  });

  final String title;
  final String sprint;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: EmptyState(
        icon: Icons.construction_outlined,
        title: title,
        subtitle: 'Kommt in $sprint.',
      ),
    );
  }
}
