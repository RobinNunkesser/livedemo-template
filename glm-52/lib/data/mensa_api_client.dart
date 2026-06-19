/// HTTP-Adapter für die OpenMensa-API des Studentenwerks Dresden.
///
/// Implementiert die verbindliche Endpoint-Matrix und die Timeout-/Retry-/
/// Fehlerpolitik aus dem Tech-Design Mensaplan:
///   - Basis-URL: https://api.studentenwerk-dresden.de/openmensa/v2
///   - Canteen ID: 6
///   - Reihenfolge: /days -> closed-Check -> /days/{date}/meals
///   - Timeout: 5s je Request
///   - Retry: genau 1x bei Timeout/Netzwerk/5xx; kein Retry bei 4xx
///   - Ungültige Meals werden stillschweigend verworfen
library;

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/allergens.dart';
import '../domain/meal.dart';
import '../domain/mensa_day.dart';
import 'mensa_repository.dart';

/// Konkreter Adapter für OpenMensa HTTP.
class MensaApiClient implements MensaRepository {
  MensaApiClient({
    http.Client? client,
    this.baseUrl = 'https://api.studentenwerk-dresden.de/openmensa/v2',
    this.canteenId = 6,
    this.timeout = const Duration(seconds: 5),
  }) : _client = client ?? http.Client();

  final http.Client _client;
  final String baseUrl;
  final int canteenId;
  final Duration timeout;

  @override
  Future<MensaDay> getDay(String date) async {
    // 1) /days -> Tag mit heutigem Datum suchen
    final List<dynamic> daysJson;
    try {
      daysJson = await _getJson('/canteens/$canteenId/days');
    } on MensaRepositoryException {
      rethrow;
    }

    final dayEntry = daysJson.cast<Map<String, dynamic>>().firstWhere(
          (d) => d['date'] == date,
          orElse: () => <String, dynamic>{},
        );

    // 3) Kein Eintrag für heute -> Leerzustand
    if (dayEntry.isEmpty) {
      return MensaDay(date: date, status: DayStatus.noData);
    }

    final isClosed = dayEntry['closed'] == true;
    // 4) closed=true -> Mensa-geschlossen-Zustand
    if (isClosed) {
      return MensaDay(date: date, status: DayStatus.closed);
    }

    // 5) /days/{date}/meals -> Gerichte laden
    final List<dynamic> mealsJson;
    try {
      mealsJson = await _getJson('/canteens/$canteenId/days/$date/meals');
    } on MensaRepositoryException {
      rethrow;
    }

    // 6) Validieren + mappen, ungültige verwerfen
    final meals = <Meal>[];
    for (final raw in mealsJson) {
      final meal = _parseMeal(raw);
      if (meal != null) meals.add(meal);
    }

    return MensaDay(date: date, status: DayStatus.open, meals: meals);
  }

  /// GET mit Timeout + genau einem Retry bei Timeout/Netzwerk/5xx.
  Future<List<dynamic>> _getJson(String path) async {
    final response = await _requestWithRetry(path);

    if (response.statusCode >= 500) {
      // 5xx -> Serverfehler (Retry wurde bereits in _requestWithRetry versucht)
      throw MensaRepositoryException(
        MensaErrorKind.http,
        'Serverfehler ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }

    if (response.statusCode >= 400) {
      // 4xx -> kein Retry
      throw MensaRepositoryException(
        MensaErrorKind.http,
        'HTTP ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }

    try {
      return jsonDecode(response.body) as List<dynamic>;
    } on FormatException catch (e) {
      throw MensaRepositoryException(
        MensaErrorKind.parse,
        'Ungültiges JSON: ${e.message}',
      );
    }
  }

  /// Führt einen GET aus. Bei Timeout/Netzwerkfehler oder 5xx genau ein Retry.
  Future<http.Response> _requestWithRetry(String path) async {
    final uri = Uri.parse('$baseUrl$path');

    http.Response response;
    bool networkFailed = false;
    try {
      response = await _client.get(uri).timeout(timeout);
    } on Exception {
      networkFailed = true;
      // Platzhalter; wird beim Retry überschrieben bzw. geworfen.
      response = http.Response('', 599);
    }

    if (networkFailed || response.statusCode >= 500) {
      // Genau ein Retry bei Netzwerkfehler/Timeout oder 5xx.
      try {
        response = await _client.get(uri).timeout(timeout);
      } on Exception catch (e) {
        throw MensaRepositoryException(
          MensaErrorKind.network,
          'Netzwerk-/Timeout-Fehler nach Retry: ${e.toString()}',
          statusCode: response.statusCode == 599 ? null : response.statusCode,
        );
      }
    }

    return response;
  }

  /// Parst ein Meal aus einem API-Eintrag; null bei ungültigem Datensatz.
  ///
  /// Pflichtfelder (Tech-Design Mensaplan):
  /// id (nicht null), name (nicht leer), category (nicht leer),
  /// mindestens ein Preisfeld.
  ///
  /// Hinweis: Die reale API liefert deutschsprachige Preisschlüssel
  /// ("Studierende", "Bedienstete"), nicht die im Tech-Design genannten
  /// englischen ("students"/"employees"). Wir akzeptieren beide.
  Meal? _parseMeal(dynamic raw) {
    if (raw is! Map<String, dynamic>) return null;

    final id = raw['id'];
    final name = raw['name'];
    final category = raw['category'];
    if (id == null || name is! String || name.trim().isEmpty) return null;
    if (category is! String || category.trim().isEmpty) return null;

    final prices = raw['prices'];
    double? priceStudent;
    double? priceEmployee;
    if (prices is Map<String, dynamic>) {
      priceStudent = _toDouble(prices['Studierende'] ?? prices['students']);
      priceEmployee = _toDouble(prices['Bedienstete'] ?? prices['employees']);
    }
    if (priceStudent == null && priceEmployee == null) return null;

    // Allergene aus notes extrahieren (Codes in Klammern).
    final notes = raw['notes'];
    final allergens = <Allergen>[];
    if (notes is List) {
      for (final note in notes) {
        if (note is String) {
          allergens.addAll(_extractAllergens(note));
        }
      }
    }

    // Bild-URL normalisieren (relativ mit // -> https:).
    String? imageUrl;
    final img = raw['image'];
    if (img is String && img.trim().isNotEmpty) {
      imageUrl = img.startsWith('//') ? 'https:$img' : img;
    }

    return Meal(
      id: id as int,
      name: name.trim(),
      category: category.trim(),
      priceStudent: priceStudent,
      priceEmployee: priceEmployee,
      imageUrl: imageUrl,
      allergens: allergens,
      foodCategory: _deriveFoodCategory(notes, name),
      soldOut: raw['soldout'] == true,
    );
  }

  /// Liest einen Allergen-Code aus einem Text wie "... (A)" oder "(3)".
  List<Allergen> _extractAllergens(String note) {
    final result = <Allergen>[];
    final codeRegex = RegExp(r'\(([A-N]|\d+)\)');
    for (final match in codeRegex.allMatches(note)) {
      final code = match.group(1);
      if (code == null) continue;
      final allergen = AllergenCatalog.byCode(code);
      if (allergen != null) result.add(allergen);
    }
    return result;
  }

  /// Leitet die Speise-Kategorie für den Filter A16 ab.
  ///
  /// Reihenfolge: vegan > vegetarisch > fisch > fleisch > sonstiges.
  /// Die reale API liefert Hinweise wie "Menü ist vegan" oder
  /// "enthält Schweinefleisch".
  FoodCategory _deriveFoodCategory(dynamic notes, String name) {
    final text = <String>[];
    if (notes is List) {
      for (final n in notes) {
        if (n is String) text.add(n.toLowerCase());
      }
    }
    final nameLower = name.toLowerCase();
    final joined = '${text.join(' ')} $nameLower';

    if (joined.contains('vegan') || joined.contains('menü ist vegan')) {
      return FoodCategory.vegan;
    }
    if (joined.contains('vegetarisch') ||
        joined.contains('menü ist vegetarisch')) {
      return FoodCategory.vegetarisch;
    }
    if (joined.contains('fisch')) {
      return FoodCategory.fisch;
    }
    if (joined.contains('fleisch') ||
        joined.contains('schweinefleisch') ||
        joined.contains('rindfleisch') ||
        joined.contains('geflügel') ||
        joined.contains('hähnchen') ||
        joined.contains('schnitzel')) {
      return FoodCategory.fleisch;
    }
    return FoodCategory.sonstiges;
  }

  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
