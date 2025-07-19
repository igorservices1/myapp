import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsViewerSmart extends StatefulWidget {
  final String link;
  final String title;

  const NewsViewerSmart({super.key, required this.link, required this.title});

  @override
  State<NewsViewerSmart> createState() => _NewsViewerSmartState();
}

class _NewsViewerSmartState extends State<NewsViewerSmart> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.link));
  }

  void _openInChrome() async {
    final encodedUrl = Uri.encodeComponent(widget.link);
    final translateUrl =
        'https://translate.google.com/translate?hl=&sl=auto&tl=en&u=$encodedUrl';

    final uri = Uri.parse(translateUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open in Chrome.")),
      );
    }
  }

  void _askLuna() {
    TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Ask Luna"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Type your question..."),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "Luna received your question: ${controller.text}",
                  ),
                ),
              );
            },
            child: const Text("Send"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C1732),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C1732),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          '🌐 News Viewer',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(child: WebViewWidget(controller: _controller)),
          Container(
            color: const Color(0xFF1E2A47),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  onPressed: _openInChrome,
                  icon: const Icon(Icons.open_in_browser),
                  label: const Text("Open in Chrome"),
                ),
                ElevatedButton.icon(
                  onPressed: _askLuna,
                  icon: const Icon(Icons.chat),
                  label: const Text("Ask Luna"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
