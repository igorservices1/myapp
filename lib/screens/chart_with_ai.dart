import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ChartWithAI extends StatefulWidget {
  final String symbol;
  const ChartWithAI({super.key, required this.symbol});

  @override
  State<ChartWithAI> createState() => _ChartWithAIState();
}

class _ChartWithAIState extends State<ChartWithAI> {
  bool isFullscreen = false;
  late final WebViewController _controller;

  String get chartUrl =>
      'https://www.tradingview.com/chart/?symbol=${widget.symbol}';

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(chartUrl));
  }

  @override
  Widget build(BuildContext context) {
    final web = WebViewWidget(controller: _controller);

    return Scaffold(
      appBar: AppBar(
        title: Text(isFullscreen ? widget.symbol : 'Grafikon + AI'),
        backgroundColor: Colors.black,
        leading: isFullscreen
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => isFullscreen = false),
              )
            : null,
        actions: [
          if (!isFullscreen)
            IconButton(
              icon: const Icon(Icons.fullscreen),
              onPressed: () => setState(() => isFullscreen = true),
            ),
        ],
      ),
      body: isFullscreen
          ? web
          : Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.45,
                  child: web,
                ),
                Expanded(
                  child: _aiPanel(),
                ),
              ],
            ),
    );
  }

  Widget _aiPanel() => Container(
        color: Colors.black,
        child: Column(
          children: [
            const Expanded(
              child: Center(
                child: Text('AI: ovde će ići odgovor',
                    style: TextStyle(color: Colors.white)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Unesi pitanje…',
                        hintStyle: const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: Colors.grey[900],
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () {/* TODO AI */},
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}
