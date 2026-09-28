import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';

/// A simple donut chart of this month's spending by category.
/// Renders nothing (returns SizedBox.shrink) when there's no data yet,
/// so it plays nicely with the empty state.
class CategorySummaryChart extends StatelessWidget {
  final Map<String, double> categoryTotals;

  const CategorySummaryChart({super.key, required this.categoryTotals});

  @override
  Widget build(BuildContext context) {
    if (categoryTotals.isEmpty) return const SizedBox.shrink();

    final entries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = entries.fold<double>(0, (sum, e) => sum + e.value);

    return Card(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            SizedBox(
              height: 110,
              width: 110,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 28,
                  sections: [
                    for (int i = 0; i < entries.length; i++)
                      PieChartSectionData(
                        value: entries[i].value,
                        color: AppTheme.categoryColors[
                            i % AppTheme.categoryColors.length],
                        showTitle: false,
                        radius: 22,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int i = 0; i < entries.length && i < 4; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: AppTheme.categoryColors[
                                  i % AppTheme.categoryColors.length],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              entries[i].key,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          Text(
                            '${(entries[i].value / total * 100).toStringAsFixed(0)}%',
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
