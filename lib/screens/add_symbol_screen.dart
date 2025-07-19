import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

class AddSymbolScreen extends StatefulWidget {
  final List<Map<String, dynamic>> vecIzabrani;
  final Function(List<Map<String, dynamic>>) onSave;

  const AddSymbolScreen({
    super.key,
    required this.vecIzabrani,
    required this.onSave,
  });

  @override
  State<AddSymbolScreen> createState() => _AddSymbolScreenState();
}

class _AddSymbolScreenState extends State<AddSymbolScreen> {
  Map<String, List<Map<String, dynamic>>> simboliPoKategoriji = {};
  List<Map<String, dynamic>> izabrani = [];
  List<Map<String, dynamic>> sviSimboli = [];
  List<Map<String, dynamic>> filtriraniSimboli = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    izabrani = [...widget.vecIzabrani];
    ucitajJson();
  }

  Future<void> ucitajJson() async {
    final String raw = await rootBundle.loadString('assets/json/symbols.json');
    final Map<String, dynamic> parsed = jsonDecode(raw);

    final novaMapa = <String, List<Map<String, dynamic>>>{};
    final svi = <Map<String, dynamic>>[];

    parsed.forEach((kategorija, lista) {
      final simboli = (lista as List)
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
      novaMapa[kategorija] = simboli;
      svi.addAll(simboli);
    });

    setState(() {
      simboliPoKategoriji = novaMapa;
      sviSimboli = svi;
      filtriraniSimboli =
          []; // prazno znači da se koristi default prikaz po kategorijama
    });
  }

  void toggleSymbol(Map<String, dynamic> simbol) {
    setState(() {
      final postoji = izabrani.any((e) => e['symbol'] == simbol['symbol']);
      if (postoji) {
        izabrani.removeWhere((e) => e['symbol'] == simbol['symbol']);
      } else {
        izabrani.add(simbol);
      }
    });
  }

  bool simbolJeIzabran(String symbol) {
    return izabrani.any((e) => e['symbol'] == symbol);
  }

  void filtriraj(String query) {
    setState(() {
      if (query.isEmpty) {
        filtriraniSimboli = [];
      } else {
        filtriraniSimboli = sviSimboli.where((simbol) {
          final symbol = simbol['symbol'].toString().toLowerCase();
          final name = (simbol['name'] ?? '').toString().toLowerCase();
          final q = query.toLowerCase();
          return symbol.contains(q) || name.contains(q);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final kategorije = simboliPoKategoriji.keys.toList();

    return Scaffold(
      backgroundColor: Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Add Symbol'),
        actions: [
          TextButton(
            onPressed: () {
              widget.onSave(izabrani);
              Navigator.pop(context, izabrani);
            },
            child: const Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: TextField(
              controller: searchController,
              onChanged: filtriraj,
              decoration: InputDecoration(
                hintText: "Pretraži simbole (npr. gold, eur, apple...)",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Color(0xFF001F3F),
              ),
            ),
          ),
        ),
      ),
      body: filtriraniSimboli.isNotEmpty
          ? ListView.builder(
              itemCount: filtriraniSimboli.length,
              itemBuilder: (_, i) {
                final simbol = filtriraniSimboli[i];
                final jeIzabran = simbolJeIzabran(simbol['symbol']);

                return ListTile(
                  leading: Text(simbol['country'] ?? '🌐'),
                  title: Text(simbol['symbol']),
                  subtitle: Text(simbol['name'] ?? ''),
                  trailing: Icon(
                    jeIzabran ? Icons.check : Icons.add,
                    color: jeIzabran ? Colors.green : Colors.grey,
                  ),
                  onTap: () => toggleSymbol(simbol),
                );
              },
            )
          : DefaultTabController(
              length: kategorije.length,
              child: Column(
                children: [
                  TabBar(
                    isScrollable: true,
                    tabs: kategorije.map((k) => Tab(text: k)).toList(),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: kategorije.map((kategorija) {
                        final simboli = simboliPoKategoriji[kategorija]!;

                        return ListView.builder(
                          itemCount: simboli.length,
                          itemBuilder: (_, i) {
                            final simbol = simboli[i];
                            final jeIzabran = simbolJeIzabran(simbol['symbol']);

                            return ListTile(
                              leading: Text(simbol['country'] ?? '🌐'),
                              title: Text(simbol['symbol']),
                              subtitle: Text(simbol['name'] ?? ''),
                              trailing: Icon(
                                jeIzabran ? Icons.check : Icons.add,
                                color: jeIzabran ? Colors.green : Colors.grey,
                              ),
                              onTap: () => toggleSymbol(simbol),
                            );
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
