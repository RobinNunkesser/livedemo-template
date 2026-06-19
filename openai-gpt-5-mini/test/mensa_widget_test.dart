import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;
import 'package:livedemo_template_mvp/features/mensa/mensa_service.dart';
import 'package:livedemo_template_mvp/features/mensa/mensa_screen.dart';
import 'package:livedemo_template_mvp/features/mensa/mensa_provider.dart';

void main() {
  testWidgets('MensaScreen shows meals from service', (tester) async {
    final mockClient = MockClient((req) async {
      if (req.url.path.endsWith('/days')) {
        final today = DateTime.now();
        final yyyy = today.year.toString().padLeft(4, '0');
        final mm = today.month.toString().padLeft(2, '0');
        final dd = today.day.toString().padLeft(2, '0');
        final date = '$yyyy-$mm-$dd';
        return http.Response(
            jsonEncode([
              {'date': date, 'closed': false}
            ]),
            200);
      }
      final body = jsonEncode([
        {
          'id': 1,
          'name': 'Gericht A',
          'category': 'Fleisch',
          'prices': {'students': 3.5}
        }
      ]);
      return http.Response(body, 200);
    });

    await tester.pumpWidget(
      ProviderScope(overrides: [
        mensaServiceProvider
            .overrideWithValue(MensaService(client: mockClient)),
      ], child: const MaterialApp(home: MensaScreen())),
    );

    // initial frame may show loading
    await tester.pumpAndSettle();
    expect(find.textContaining('Gericht A'), findsOneWidget);
  });

  testWidgets('MensaScreen shows error state', (tester) async {
    final mockClient = MockClient((req) async => http.Response('error', 500));

    await tester.pumpWidget(
      ProviderScope(overrides: [
        mensaServiceProvider
            .overrideWithValue(MensaService(client: mockClient)),
      ], child: const MaterialApp(home: MensaScreen())),
    );

    await tester.pumpAndSettle();
    expect(find.textContaining('Mensa nicht verfügbar'), findsOneWidget);
    expect(find.text('Neu laden'), findsOneWidget);
  });
}
