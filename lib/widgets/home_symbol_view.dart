import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import '../services/forex_service.dart';

class HomeSymbolView extends StatefulWidget {
  final String jsonPath;
  final Function(List<Map<String, dynamic>>)? onSymbolsChanged;

  const HomeSymbolView({
    super.key,
    required this.jsonPath,
    this.onSymbolsChanged,
  });

  @override
  State<HomeSymbolView> createState() => _HomeSymbolViewState();
}

class _HomeSymbolViewState extends State<HomeSymbolView> {
  List<Map<String, dynamic>> simboli = [];
  Map<String, double> cene = {};
  bool loading = true;
  String searchQuery = ''; // ✅ za pretragu

  @override
  void initState() {
    super.initState();
    _ucitajSimboliIzJsona();
  }

  Future<void> _ucitajSimboliIzJsona() async {
    final String jsonString = await rootBundle.loadString(widget.jsonPath);
    final List<dynamic> jsonData = json.decode(jsonString);
    simboli = jsonData.cast<Map<String, dynamic>>();

    widget.onSymbolsChanged?.call(simboli);

    for (var s in simboli) {
      final symbol = s['symbol'];
      double? price;

      try {
        if (symbol.contains('/')) {
          price = await ForexService.fetchExchangeRateForSymbol(symbol);
        } else {
          price = await ApiService().fetchPrice(symbol);
        }
      } catch (e) {
        print('Greška za $symbol: $e');
      }

      if (price != null) {
        cene[symbol] = price;
      }
    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    final filtriraniSimboli = simboli
        .where(
          (s) => s['symbol'].toLowerCase().contains(searchQuery.toLowerCase()),
        )
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ Pretraga
          TextField(
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Pretraži simbole...',
              hintStyle: const TextStyle(color: Colors.white70),
              prefixIcon: const Icon(Icons.search, color: Colors.white70),
              filled: true,
              fillColor: Colors.white12,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 20),

          // ✅ Lista simbola sa mogućnošću brisanja
          ...filtriraniSimboli.map((s) {
            final symbol = s['symbol'];
            final name = s['name'] ?? '';
            final cena = cene[symbol];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$symbol – $name',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: () {
                        setState(() {
                          simboli.remove(s);
                          cene.remove(symbol);
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  cena != null
                      ? '$symbol: ${cena.toStringAsFixed(2)}'
                      : '$symbol: Loading...',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const Divider(color: Colors.white12),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }
}
