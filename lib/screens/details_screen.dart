import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/screens/edit_expense_screen.dart';
import 'package:expense_tracker/state/app_state.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DetailsScreen extends StatelessWidget {
  final Expense expense;

  const DetailsScreen({super.key, required this.expense});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    final currentIndex = appState.expenses.indexWhere(
      (e) => e.id == expense.id,
    );
    if (currentIndex == -1) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: const BackButton(color: Colors.black),
        ),
        body: const Center(
          child: Text(
            'Expense not found.',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    final currentExpense = appState.expenses[currentIndex];
    final relatedExpenses = appState.expenses
        .where((e) => e.category == currentExpense.category)
        .toList();
    final categoryTotal = relatedExpenses.fold(
      0.0,
      (sum, item) => sum + item.amount,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopSection(
              context,
              currentExpense,
              currentIndex,
              categoryTotal,
            ),
            const SizedBox(height: 30),
            _buildChartSection(relatedExpenses),
            const SizedBox(height: 30),
            _buildCategorySelector(currentExpense),
            const SizedBox(height: 20),
            Expanded(child: _buildBottomList(relatedExpenses)),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSection(
    BuildContext context,
    Expense currentExpense,
    int currentIndex,
    double categoryTotal,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '- \$${categoryTotal.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF120216),
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                currentExpense.category,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Monthly summary',
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('MMMM, yyyy').format(DateTime.now()),
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
          Column(
            children: [
              _actionIconButton(
                icon: Icons.edit,
                bg: Colors.grey.shade50,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditExpenseScreen(
                        expense: currentExpense,
                        index: currentIndex,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _actionIconButton(
                icon: Icons.delete,
                bg: Colors.grey.shade50,
                onPressed: () => _confirmDelete(context, currentExpense),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionIconButton({
    required IconData icon,
    required Color bg,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 20, color: const Color(0xFF120216)),
        tooltip: icon == Icons.edit ? 'Edit expense' : 'Delete expense',
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    Expense currentExpense,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete expense?'),
          content: Text('Delete "${currentExpense.name}" permanently?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true && context.mounted) {
      context.read<MyAppState>().deleteExpense(currentExpense);
      Navigator.pop(context);
    }
  }

  Widget _buildChartSection(List<Expense> relatedExpenses) {
    // Dynamically calculate chart based on recent 6 months for this category
    final now = DateTime.now();
    final List<double> values = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
    final List<String> labels = [];

    for (int i = 5; i >= 0; i--) {
      DateTime month = DateTime(now.year, now.month - i, 1);
      labels.add(DateFormat('MMM').format(month));
      double monthTotal = relatedExpenses
          .where(
            (e) => e.date.year == month.year && e.date.month == month.month,
          )
          .fold(0.0, (sum, item) => sum + item.amount);
      values[5 - i] = monthTotal;
    }

    final maxValue = values.fold(0.0, (a, b) => a > b ? a : b);
    final normalizedValues = maxValue > 0
        ? values.map((v) => (v / maxValue) * 60.0).toList()
        : [10.0, 10.0, 10.0, 10.0, 10.0, 10.0]; // fallback flat chart

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const Divider(color: Color(0xFFF0F0F0), thickness: 1.5),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(normalizedValues.length, (index) {
              final isLast = index == normalizedValues.length - 1;
              return Column(
                children: [
                  Container(
                    width: 26,
                    height: normalizedValues[index] + 4,
                    decoration: BoxDecoration(
                      color: isLast
                          ? const Color(0xFFEF8767)
                          : const Color(0xFFF7F4F7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    labels[index],
                    style: TextStyle(
                      color: isLast
                          ? const Color(0xFF120216)
                          : Colors.grey.shade400,
                      fontWeight: isLast ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
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

  Widget _buildCategorySelector(Expense currentExpense) {
    // Only showing relevant subset of categories based on usage
    final categories = [
      'Food & Drink',
      'Clothing',
      'Fuel',
      'Other',
      'Electronics',
      'Transport',
    ];
    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected =
              cat == currentExpense.category ||
              (cat == 'Other' && !categories.contains(currentExpense.category));
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF8F659A) : Colors.transparent,
              borderRadius: BorderRadius.circular(24),
              border: isSelected
                  ? null
                  : Border.all(color: Colors.grey.shade200),
            ),
            child: Text(
              cat,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade600,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomList(List<Expense> relatedExpenses) {
    if (relatedExpenses.isEmpty) {
      return Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFF42224A),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(36),
            topRight: Radius.circular(36),
          ),
        ),
      );
    }

    final sortedExpenses = List<Expense>.from(relatedExpenses)
      ..sort((a, b) => b.date.compareTo(a.date));

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF42224A),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(36),
          topRight: Radius.circular(36),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
      child: ListView(
        children: [
          const Text(
            'Category Transactions',
            style: TextStyle(color: Color(0xFF8F659A), fontSize: 14),
          ),
          const SizedBox(height: 20),
          ...sortedExpenses.map((e) => _buildDarkTransactionTile(e)),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildDarkTransactionTile(Expense expense) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              expense.categoryIcon,
              color: const Color(0xFF8F659A),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('dd MMMM yyyy').format(expense.date),
                  style: const TextStyle(
                    color: Color(0xFF8F659A),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '- \$${expense.amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
