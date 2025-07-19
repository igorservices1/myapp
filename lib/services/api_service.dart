import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String _apiKey = 'a5879165ff4f4d03ba6e3a218a31cb24';

  Future<double?> fetchPrice(String symbol) async {
    final url = Uri.parse(
      'https://api.twelvedata.com/price?symbol=$symbol&apikey=$_apiKey',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data.containsKey('price')) {
        return double.tryParse(data['price']);
      } else {
        print('Greška: ${data['message'] ?? 'Nepoznata greška'}');
      }
    } else {
      print('Greška pri pozivu API-a: ${response.statusCode}');
    }
    return null;
  }
}
