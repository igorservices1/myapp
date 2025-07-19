import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LiveCalendarScreen extends StatefulWidget {
  const LiveCalendarScreen({super.key});

  @override
  State<LiveCalendarScreen> createState() => _LiveCalendarScreenState();
}

class _LiveCalendarScreenState extends State<LiveCalendarScreen> {
  late WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse('https://www.forexfactory.com/calendar'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Economic Calendar'),
        backgroundColor: Colors.black,
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
