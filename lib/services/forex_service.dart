import 'dart:convert';
import 'package:http/http.dart' as http;

class ForexService {
  /// Dohvata sve kurseve za baznu valutu (npr. USD)
  static Future<Map<String, double>> fetchExchangeRates({
    required String base,
    required List<String> symbols,
  }) async {
    final url = Uri.parse('https://open.er-api.com/v6/latest/$base');

    final response = await http.get(url);
    print('API odgovor: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data.containsKey('rates')) {
        final Map<String, dynamic> rates = data['rates'];

        // Vraćamo samo one simbole koje tražimo
        final filtered = <String, double>{};
        for (var symbol in symbols) {
          if (rates.containsKey(symbol)) {
            filtered[symbol] = (rates[symbol] as num).toDouble();
          }
        }
        return filtered;
      } else {
        throw Exception('Nedostaje "rates" u odgovoru API-ja.');
      }
    } else {
      throw Exception('Greška API-ja: ${response.statusCode}');
    }
  }

  /// Dohvata kurs za jedan simbol (npr. EUR/USD)
  static Future<double> fetchExchangeRateForSymbol(String symbol) async {
    final parts = symbol.split('/');
    if (parts.length != 2) {
      throw Exception('Neispravan simbol: $symbol');
    }

    final base = parts[0];
    final target = parts[1];

    final url = Uri.parse('https://open.er-api.com/v6/latest/$base');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final rates = data['rates'];
      if (rates != null && rates.containsKey(target)) {
        return (rates[target] as num).toDouble();
      } else {
        throw Exception('Nema kursa za $symbol');
      }
    } else {
      throw Exception('Greška pri pozivanju API-ja');
    }
  }
}
