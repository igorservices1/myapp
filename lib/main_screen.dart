import 'package:flutter/material.dart';
import 'screens/news_screen.dart';
import 'screens/education/education_home.dart';
import '../services/api_service.dart';
import '../services/forex_service.dart';
import 'screens/add_symbol_screen.dart';
import '../helpers/preferences_helper.dart';
import 'dart:async';
import 'screens/chart_with_ai.dart';
import 'screens/economic_calendar_screen.dart';
import 'screens/live_calendar_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> izabraniSimboli = [];
  final ValueNotifier<Map<String, double>> forexRates = ValueNotifier({});
  Map<String, double> prethodneCene = {};

  @override
  void initState() {
    super.initState();
    ucitajSimboli(); // učitaj simbole i cene pri pokretanju

    // 🔁 Automatsko osvežavanje svakih 30 sekundi
    Timer.periodic(Duration(seconds: 60), (timer) {
      if (izabraniSimboli.isNotEmpty) {
        fetchCeneZaSimbol(izabraniSimboli);
      }
    });
  }

  // ✅ Učitaj iz memorije simbole i cene
  void ucitajSimboli() async {
    final ucitani = await PreferencesHelper.loadSimboliICene();

    setState(() {
      izabraniSimboli = ucitani;
      for (var s in ucitani) {
        forexRates.value[s['symbol']] = s['price'];
      }
    });

    if (ucitani.isNotEmpty) {
      fetchCeneZaSimbol(ucitani);
    }
  }

  // ✅ Sačuvaj u memoriju simbole i cene
  void sacuvajSimboli() async {
    await PreferencesHelper.saveSimboliICene(izabraniSimboli, forexRates.value);
  }

  void fetchCeneZaSimbol(List<Map<String, dynamic>> simboli) async {
    print("⏱ Osvežavam cene za ${simboli.length} simbola...");
    final novaMapa = Map<String, double>.from(
      forexRates.value,
    ); // kopija postojećih
    for (var s in simboli) {
      final symbol = s['symbol'];
      print("🔄 Osvežavam simbol: $symbol");
      double? price;

      if (symbol.contains('/')) {
        final parts = symbol.split('/');
        if (parts.length == 2) {
          final base = parts[0];
          final target = parts[1];
          try {
            final rates = await ForexService.fetchExchangeRates(
              base: base,
              symbols: [target],
            );
            price = rates[target];
          } catch (e) {
            print('Greška pri fetchExchangeRates: $e');
          }
        }
      } else {
        try {
          price = await ApiService().fetchPrice(symbol);
        } catch (e) {
          print('Greška pri fetchPrice: $e');
        }
      }

      if (price != null) {
        if (novaMapa.containsKey(symbol)) {
          prethodneCene[symbol] = novaMapa[symbol]!;
        }
        novaMapa[symbol] = price;
      }
    }

    forexRates.value = novaMapa; // ✅ automatski pokreće rebuild
    sacuvajSimboli();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    final List<Widget> pages = <Widget>[
      // HOME PAGE
      Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/main_bg.jpg'),
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
          ), // 👈 zatvara Container

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  SizedBox(height: screenHeight * 0.125),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB4982C),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    child: const Text(
                      'VIEW PLANS',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final rezultat = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddSymbolScreen(
                            vecIzabrani: izabraniSimboli,
                            onSave: (noviSimboli) {
                              setState(() {
                                izabraniSimboli = noviSimboli;
                              });
                              fetchCeneZaSimbol(noviSimboli);
                              sacuvajSimboli();
                            },
                          ),
                        ),
                      );

                      if (rezultat != null &&
                          rezultat is List<Map<String, dynamic>>) {
                        setState(() {
                          izabraniSimboli = rezultat;
                        });
                        fetchCeneZaSimbol(rezultat);
                        sacuvajSimboli();
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text("Add Symbols"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (izabraniSimboli.isEmpty)
                    const Text(
                      "Nema dodatih simbola",
                      style: TextStyle(color: Colors.white70),
                    )
                  else
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: ValueListenableBuilder<Map<String, double>>(
                        valueListenable: forexRates,
                        builder: (context, rates, _) {
                          return ListView.builder(
                            itemCount: izabraniSimboli.length,
                            itemBuilder: (context, index) {
                              final simbol = izabraniSimboli[index];
                              final cena = rates[simbol['symbol']];

                              return Card(
                                color: Colors.black.withOpacity(0.6),
                                child: ListTile(
                                  onTap: () {
                                    final symbol = simbol['symbol'];
                                    final formatted =
                                        'OANDA:${symbol.replaceAll('/', '')}';

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ChartWithAI(symbol: formatted),
                                      ),
                                    );
                                  },
                                  title: Text(
                                    simbol['symbol'],
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  subtitle: Text(
                                    simbol['name'] ?? '',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                  ),
                                  trailing: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        cena?.toStringAsFixed(4) ?? '...',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      if (prethodneCene.containsKey(
                                            simbol['symbol'],
                                          ) &&
                                          rates.containsKey(simbol['symbol']))
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              rates[simbol['symbol']]! >
                                                      prethodneCene[
                                                          simbol['symbol']]!
                                                  ? Icons.arrow_upward
                                                  : Icons.arrow_downward,
                                              color: rates[simbol['symbol']]! >
                                                      prethodneCene[
                                                          simbol['symbol']]!
                                                  ? Colors.green
                                                  : Colors.red,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              (() {
                                                final nova =
                                                    rates[simbol['symbol']]!;
                                                final stara = prethodneCene[
                                                    simbol['symbol']]!;
                                                final procenat =
                                                    ((nova - stara) / stara) *
                                                        100;
                                                return '${procenat >= 0 ? '+' : ''}${procenat.toStringAsFixed(2)}%';
                                              })(),
                                              style: TextStyle(
                                                color: rates[
                                                            simbol['symbol']]! >
                                                        prethodneCene[
                                                            simbol['symbol']]!
                                                    ? Colors.green
                                                    : Colors.red,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        )
                                      else
                                        const Text(
                                          '...',
                                          style: TextStyle(
                                            color: Colors.white70,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                ], // 👈 Zatvara children liste
              ), // 👈 Zatvara Column
            ), // 👈 Zatvara SingleChildScrollView
          ), // 👈 Zatvara SafeArea
        ],
      ), // 👈 Zatvara Stack
      // AI ANALYZE PAGE
      const Stack(
        children: [
          Positioned.fill(child: ColoredBox(color: Colors.white)),
          SafeArea(
            child: Center(
              child: Text(
                'AI Analyze Page',
                style: TextStyle(fontSize: 24, color: Colors.black),
              ),
            ),
          ),
        ],
      ),

      // CHAT PAGE
      const Stack(
        children: [
          Positioned.fill(child: ColoredBox(color: Colors.white)),
          SafeArea(
            child: Center(
              child: Text(
                'Chat Page',
                style: TextStyle(fontSize: 24, color: Colors.black),
              ),
            ),
          ),
        ],
      ),

      // EDUCATION PAGE
      const EducationHome(),

      // EMPTY PAGE
      const SizedBox(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF121212),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey[400],
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 4) {
            showModalBottomSheet(
              context: context,
              backgroundColor: const Color(0xFF1A1A1A),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              builder: (BuildContext context) {
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: const Icon(
                            Icons.newspaper,
                            color: Colors.white,
                          ),
                          title: const Text(
                            '📰 Vesti',
                            style: TextStyle(color: Colors.white),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const NewsScreen(),
                              ),
                            );
                          },
                        ),
                        ListTile(
                          leading: const Icon(
                            Icons.calendar_today,
                            color: Colors.white,
                          ),
                          title: const Text(
                            '📆 Ekonomski kalendar',
                            style: TextStyle(color: Colors.white),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    EconomicCalendarScreen(), // 👈 ti napraviš taj ekran
                              ),
                            );
                          },
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const LiveCalendarScreen()),
                            );
                          },
                          child: const Text("Live Calendar (Web)"),
                        ),
                        const Divider(color: Colors.white24),
                        const ListTile(
                          leading: Icon(Icons.settings, color: Colors.white),
                          title: Text(
                            'Podešavanja',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            setState(() {
              _selectedIndex = index;
            });
          }
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'AI'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Edu'),
          BottomNavigationBarItem(
            icon: RotatedBox(quarterTurns: 1, child: Icon(Icons.more_vert)),
            label: 'More',
          ),
        ],
      ),
    );
  }
}
