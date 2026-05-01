import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/mood_entry.dart';

class InsightChart extends StatelessWidget {
  final List<MoodEntry> entries;
  final int days;

  const InsightChart({
    super.key,
    required this.entries,
    this.days = 7,
  });

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return _EmptyChart();
    }

    // Build one spot per day (average if multiple entries that day)
    final Map<String, List<int>> byDay = {};
    for (final e in entries) {
      final key = DateFormat('MM/dd').format(e.loggedAt);
      byDay.putIfAbsent(key, () => []).add(e.moodScore);
    }

    final sortedKeys = byDay.keys.toList()..sort();
    final spots = <FlSpot>[];
    for (var i = 0; i < sortedKeys.length; i++) {
      final scores = byDay[sortedKeys[i]]!;
      final avg = scores.reduce((a, b) => a + b) / scores.length;
      spots.add(FlSpot(i.toDouble(), avg));
    }

    return Container(
      height: 180,
      padding: const EdgeInsets.only(top: 12, right: 16),
      child: LineChart(
        LineChartData(
          minY: 0.5,
          maxY: 4.5,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 1,
            getDrawingHorizontalLine: (value) => FlLine(
              color: const Color(0xFF2A3240),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 38,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final labels = {1.0: 'Hard', 2.0: 'Okay', 3.0: 'Good', 4.0: 'Great'};
                  final label = labels[value];
                  if (label == null) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Text(
                      label,
                      style: GoogleFonts.nunito(
                        fontSize: 10,
                        color: const Color(0xFF8B949E),
                      ),
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= sortedKeys.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      sortedKeys[idx],
                      style: GoogleFonts.nunito(
                        fontSize: 10,
                        color: const Color(0xFF8B949E),
                      ),
                    ),
                  );
                },
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.4,
              color: const Color(0xFF7C6FCD),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, bar, index) =>
                    FlDotCirclePainter(
                  radius: 4,
                  color: const Color(0xFF7C6FCD),
                  strokeWidth: 2,
                  strokeColor: const Color(0xFF0D1117),
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF7C6FCD).withOpacity(0.3),
                    const Color(0xFF7C6FCD).withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      alignment: Alignment.center,
      child: Text(
        'No mood data yet.\nStart logging to see your trends.',
        textAlign: TextAlign.center,
        style: GoogleFonts.nunito(
          color: const Color(0xFF8B949E),
          fontSize: 14,
          height: 1.6,
        ),
      ),
    );
  }
}