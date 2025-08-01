// lib/models/chart_data.dart

class ChartData {
  final DateTime time;
  final double open;
  final double high;
  final double low;
  final double close;

  ChartData({
    required this.time,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
  });
}
