import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/state/app_state.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  String _selectedRange = '30D';

  static const List<String> _ranges = ['7D', '30D', '90D', '12M'];

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();
    final now = DateTime.now();
    final currentExpenses = _filterByRange(appState.expenses, _selectedRange, now);
    final previousExpenses = _previousPeriodExpenses(appState.expenses, _selectedRange, now);

    final currentTotal = currentExpenses.fold(0.0, (sum, item) => sum + item.amount);
    final previousTotal = previousExpenses.fold(0.0, (sum, item) => sum + item.amount);
    final changePercent = _calculateChangePercent(currentTotal, previousTotal);
    final dailyAverage = _rangeDays(_selectedRange) == 0
        ? 0.0
        : currentTotal / _rangeDays(_selectedRange);
    final topDay = _highestSpendDay(currentExpenses);
    final categoryTotals = _categoryTotals(currentExpenses);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F4F7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 18),
              _buildRangeSelector(),
              const SizedBox(height: 20),
              _buildSummaryCard(currentTotal, previousTotal, changePercent),
              const SizedBox(height: 20),
              _buildInsightRow(dailyAverage, topDay, currentExpenses.length),
              const SizedBox(height: 24),
              _buildTrendSection(currentExpenses, now),
              const SizedBox(height: 24),
              _buildCategoryBreakdown(categoryTotals, currentTotal),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Stats',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            height: 1.2,
            color: Color(0xFF120216),
          ),
        ),
        Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
              ),
            ],
          ),
          child: const Icon(Icons.bar_chart, color: Color(0xFF42224A)),
        ),
      ],
    );
  }

  Widget _buildRangeSelector() {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _ranges.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final range = _ranges[index];
          final isSelected = range == _selectedRange;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedRange = range;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF8F659A) : Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Text(
                range,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF120216),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(double currentTotal, double previousTotal, double changePercent) {
    final isIncrease = changePercent >= 0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF42224A),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Period Spending',
            style: TextStyle(
              color: Color(0xFF8F659A),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '\$${currentTotal.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(
                Icons.history,
                color: Color(0xFF8F659A),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Previous period: \$${previousTotal.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Color(0xFF8F659A),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                isIncrease ? Icons.trending_up : Icons.trending_down,
                color: const Color(0xFF8F659A),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                '${isIncrease ? '+' : ''}${changePercent.toStringAsFixed(1)}% vs previous period',
                style: const TextStyle(
                  color: Color(0xFF8F659A),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsightRow(double dailyAverage, DateTime? topDay, int expenseCount) {
    return Row(
      children: [
        Expanded(
          child: _insightCard(
            title: 'Avg / Day',
            value: '\$${dailyAverage.toStringAsFixed(2)}',
            icon: Icons.calendar_today,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _insightCard(
            title: 'Top Spend Day',
            value: topDay == null ? '-' : DateFormat('dd MMM').format(topDay),
            icon: Icons.bolt,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _insightCard(
            title: 'Receipts',
            value: '$expenseCount',
            icon: Icons.receipt_long,
          ),
        ),
      ],
    );
  }

  Widget _insightCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF8F659A)),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(color: Colors.grey, fontSize: 11),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF120216),
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendSection(List<Expense> expenses, DateTime now) {
    final points = _trendPoints(expenses, now, _selectedRange);
    final values = points.map((point) => point.value).toList();
    final labels = points.map((point) => point.label).toList();

    final maxValue = values.fold(0.0, (a, b) => a > b ? a : b);
    final normalizedValues = maxValue > 0
        ? values.map((value) => (value / maxValue) * 56).toList()
        : List<double>.filled(points.length, 12);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trend ($_selectedRange)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF120216),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(normalizedValues.length, (index) {
              final isLatest = index == normalizedValues.length - 1;
              return Column(
                children: [
                  Container(
                    width: 20,
                    height: normalizedValues[index] + 6,
                    decoration: BoxDecoration(
                      color: isLatest
                          ? const Color(0xFFEF8767)
                          : const Color(0xFF8F659A).withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    labels[index],
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isLatest ? FontWeight.bold : FontWeight.w500,
                      color: isLatest ? const Color(0xFF120216) : Colors.grey,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown(
    Map<String, double> categoryTotals,
    double grandTotal,
  ) {
    if (categoryTotals.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Text(
          'No data in this range. Try another period.',
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
      );
    }

    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Top Categories',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        ...sortedCategories.map((entry) {
          final percent = grandTotal > 0 ? (entry.value / grandTotal) * 100 : 0;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.key,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Color(0xFF120216),
                        ),
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: percent / 100,
                          minHeight: 7,
                          backgroundColor: const Color(0xFFF0E9F2),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF8F659A),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${entry.value.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF120216),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${percent.toStringAsFixed(1)}%',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Map<String, double> _categoryTotals(List<Expense> expenses) {
    final totals = <String, double>{};
    for (final expense in expenses) {
      totals[expense.category] =
          (totals[expense.category] ?? 0) + expense.amount;
    }
    return totals;
  }

  List<Expense> _filterByRange(List<Expense> expenses, String range, DateTime now) {
    if (range == '12M') {
      final start = DateTime(now.year - 1, now.month, now.day);
      return expenses.where((expense) => !expense.date.isBefore(start)).toList();
    }

    final days = _rangeDays(range);
    final start = now.subtract(Duration(days: days - 1));
    return expenses.where((expense) => !expense.date.isBefore(start)).toList();
  }

  List<Expense> _previousPeriodExpenses(List<Expense> expenses, String range, DateTime now) {
    if (range == '12M') {
      final currentStart = DateTime(now.year - 1, now.month, now.day);
      final previousStart = DateTime(now.year - 2, now.month, now.day);
      return expenses
          .where((expense) =>
              expense.date.isAfter(previousStart) && expense.date.isBefore(currentStart))
          .toList();
    }

    final days = _rangeDays(range);
    final currentStart = now.subtract(Duration(days: days - 1));
    final previousStart = currentStart.subtract(Duration(days: days));
    return expenses
        .where((expense) =>
            (expense.date.isAtSameMomentAs(previousStart) || expense.date.isAfter(previousStart)) &&
            expense.date.isBefore(currentStart))
        .toList();
  }

  int _rangeDays(String range) {
    return switch (range) {
      '7D' => 7,
      '30D' => 30,
      '90D' => 90,
      '12M' => 365,
      _ => 30,
    };
  }

  double _calculateChangePercent(double current, double previous) {
    if (previous == 0) {
      return current == 0 ? 0 : 100;
    }
    return ((current - previous) / previous) * 100;
  }

  DateTime? _highestSpendDay(List<Expense> expenses) {
    if (expenses.isEmpty) {
      return null;
    }

    final totalsByDay = <String, double>{};
    for (final expense in expenses) {
      final key = DateFormat('yyyy-MM-dd').format(expense.date);
      totalsByDay[key] = (totalsByDay[key] ?? 0) + expense.amount;
    }

    final topEntry = totalsByDay.entries.reduce((a, b) => a.value >= b.value ? a : b);
    return DateTime.parse(topEntry.key);
  }

  List<_TrendPoint> _trendPoints(List<Expense> expenses, DateTime now, String range) {
    if (range == '12M') {
      final points = <_TrendPoint>[];
      for (int i = 5; i >= 0; i--) {
        final month = DateTime(now.year, now.month - i, 1);
        final total = expenses
            .where((expense) =>
                expense.date.year == month.year && expense.date.month == month.month)
            .fold(0.0, (sum, item) => sum + item.amount);
        points.add(_TrendPoint(DateFormat('MMM').format(month), total));
      }
      return points;
    }

    final days = _rangeDays(range);
    final bucketSize = (days / 6).ceil();
    final start = now.subtract(Duration(days: days - 1));
    final points = <_TrendPoint>[];

    for (int i = 0; i < 6; i++) {
      final bucketStart = start.add(Duration(days: i * bucketSize));
      final bucketEnd = i == 5
          ? now
          : bucketStart.add(Duration(days: bucketSize - 1));

      final total = expenses
          .where((expense) =>
              (expense.date.isAtSameMomentAs(bucketStart) || expense.date.isAfter(bucketStart)) &&
              (expense.date.isAtSameMomentAs(bucketEnd) || expense.date.isBefore(bucketEnd)))
          .fold(0.0, (sum, item) => sum + item.amount);

      points.add(_TrendPoint(
        DateFormat('dd/MM').format(bucketStart),
        total,
      ));
    }

    return points;
  }
}

class _TrendPoint {
  final String label;
  final double value;

  _TrendPoint(this.label, this.value);
}
