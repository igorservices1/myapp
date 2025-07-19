import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class EconomicCalendarScreen extends StatefulWidget {
  const EconomicCalendarScreen({super.key});

  @override
  State<EconomicCalendarScreen> createState() => _EconomicCalendarScreenState();
}

class _EconomicCalendarScreenState extends State<EconomicCalendarScreen> {
  List<Map<String, dynamic>> events = [];

  @override
  void initState() {
    super.initState();
    loadEconomicCalendar().then((data) {
      setState(() {
        events = data;
      });
    });
  }

  Future<List<Map<String, dynamic>>> loadEconomicCalendar() async {
    final String jsonStr =
        await rootBundle.loadString('assets/calendar/2025-07-20.json');
    return List<Map<String, dynamic>>.from(json.decode(jsonStr));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
          title: const Text("Economic Calendar"),
          backgroundColor: Colors.black87),
      body: events.isEmpty
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                final e = events[index];
                return Card(
                  color: Colors.grey[900],
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text(
                        '${e["time"]} - ${e["currency"]} - ${e["event"]}',
                        style: const TextStyle(color: Colors.white)),
                    subtitle: Text(
                        'Forecast: ${e["forecast"] ?? "-"} | Previous: ${e["previous"] ?? "-"}',
                        style: const TextStyle(color: Colors.grey)),
                    trailing: Text(e["date"],
                        style: const TextStyle(color: Colors.white70)),
                  ),
                );
              },
            ),
    );
  }
}
