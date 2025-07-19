import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import 'news_viewer_smart.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  List<Map<String, String>> vesti = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    ucitajVesti();
  }

  Future<void> ucitajVesti() async {
    try {
      final response = await http.get(
        Uri.parse('https://www.investing.com/rss/news_25.rss'),
        headers: {'User-Agent': 'Mozilla/5.0'},
      );
      final document = xml.XmlDocument.parse(response.body);
      final items = document.findAllElements('item');

      setState(() {
        vesti = items.map((item) {
          return {
            'title': item.findElements('title').first.text,
            'link': item.findElements('link').first.text,
          };
        }).toList();
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C1732),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C1732),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          '📰 Forex News',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : ListView.builder(
              itemCount: vesti.length,
              itemBuilder: (context, index) {
                final vest = vesti[index];
                return NewsCard(
                  title: vest['title'] ?? '',
                  url: vest['link'] ?? '',
                );
              },
            ),
    );
  }
}

class NewsCard extends StatelessWidget {
  final String title;
  final String url;

  const NewsCard({super.key, required this.title, required this.url});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1E2A47),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NewsViewerSmart(link: url, title: title),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
