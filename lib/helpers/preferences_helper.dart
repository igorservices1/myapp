import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PreferencesHelper {
  // ✅ ČUVANJE SIMBOLA I CENA
  static Future<void> saveSimboliICene(
    List<Map<String, dynamic>> simboli,
    Map<String, double> cene,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    List<Map<String, dynamic>> listaZaCuvanje = simboli.map((simbol) {
      final symbol = simbol['symbol'];
      return {'symbol': symbol, 'price': cene[symbol] ?? 0.0};
    }).toList();

    await prefs.setString('sacuvaniSimboli', jsonEncode(listaZaCuvanje));
  }

  // ✅ UČITAVANJE SIMBOLA I CENA
  static Future<List<Map<String, dynamic>>> loadSimboliICene() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('sacuvaniSimboli');

    if (jsonString != null) {
      final List<dynamic> lista = jsonDecode(jsonString);
      return lista
          .map(
            (e) => {
              'symbol': e['symbol'],
              'price': (e['price'] as num).toDouble(),
            },
          )
          .toList();
    } else {
      return [];
    }
  }

  // 🔒 (ZA KASNIJE) ČUVANJE PODEŠAVANJA GRAFIKONA
  static Future<void> saveChartSettings(
    String interval,
    List<String> indikatori,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('chartInterval', interval);
    await prefs.setStringList('chartIndicators', indikatori);
  }

  static Future<String> loadChartInterval() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('chartInterval') ?? '1H';
  }

  static Future<List<String>> loadChartIndicators() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('chartIndicators') ?? [];
  }
}
