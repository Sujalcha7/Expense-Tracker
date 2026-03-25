import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/screens/edit_expense_screen.dart';
import 'package:expense_tracker/state/app_state.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/screens/details_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    final expenses = appState.expenses;
    final totalOutcome = expenses.fold(0.0, (sum, item) => sum + item.amount);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F4F7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 30),
              _buildOutcomeCard(totalOutcome, expenses),
              const SizedBox(height: 30),
              _buildTransactionsList(expenses),
              const SizedBox(height: 80), // Padding for bottom nav
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
          'Hello,\nUser',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            height: 1.2,
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
          child: IconButton(icon: const Icon(Icons.search), onPressed: () {}),
        ),
      ],
    );
  }

  Widget _buildOutcomeCard(double totalOutcome, List<Expense> expenses) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Outcome',
                style: TextStyle(color: Color(0xFF8F659A), fontSize: 16),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0xFF8F659A),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '\$${totalOutcome.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          _buildMiniChart(expenses),
        ],
      ),
    );
  }

  Widget _buildMiniChart(List<Expense> expenses) {
    // Dynamically calculate chart based on recent 5 months
    final now = DateTime.now();
    final List<double> values = [0.0, 0.0, 0.0, 0.0, 0.0];
    final List<String> labels = [];

    for (int i = 4; i >= 0; i--) {
      DateTime month = DateTime(now.year, now.month - i, 1);
      labels.add(DateFormat('MMM').format(month));
      double monthTotal = expenses
          .where(
            (e) => e.date.year == month.year && e.date.month == month.month,
          )
          .fold(0.0, (sum, item) => sum + item.amount);
      values[4 - i] = monthTotal;
    }

    // Normalize for chart height (max 60px)
    final maxValue = values.fold(0.0, (a, b) => a > b ? a : b);
    final normalizedValues = maxValue > 0
        ? values.map((v) => (v / maxValue) * 40.0).toList()
        : [10.0, 10.0, 10.0, 10.0, 10.0]; // fallback flat chart if empty

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(normalizedValues.length, (index) {
        final isLast = index == normalizedValues.length - 1;
        return Column(
          children: [
            Container(
              width: 14,
              height: normalizedValues[index] + 4, // Min height line
              decoration: BoxDecoration(
                color: isLast
                    ? const Color(0xFFEF8767)
                    : const Color(0xFF8F659A).withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              labels[index],
              style: const TextStyle(color: Color(0xFF8F659A), fontSize: 12),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildTransactionsList(List<Expense> expenses) {
    if (expenses.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 20),
        child: Center(
          child: Text(
            'No expenses yet. Add one!',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ),
      );
    }

    // Sort expenses by date descending
    final sortedExpenses = List<Expense>.from(expenses)
      ..sort((a, b) => b.date.compareTo(a.date));

    final today = DateTime.now();
    final todayExpenses = sortedExpenses
        .where(
          (e) =>
              e.date.day == today.day &&
              e.date.month == today.month &&
              e.date.year == today.year,
        )
        .toList();
    final pastExpenses = sortedExpenses
        .where(
          (e) =>
              e.date.day != today.day ||
              e.date.month != today.month ||
              e.date.year != today.year,
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (todayExpenses.isNotEmpty) ...[
          const Text(
            'Today',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...todayExpenses.map((e) => TransactionTile(expense: e)),
          const SizedBox(height: 20),
        ],
        if (pastExpenses.isNotEmpty) ...[
          Text(
            'Past Expenses',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...pastExpenses.map((e) => TransactionTile(expense: e)),
        ],
      ],
    );
  }
}

class TransactionTile extends StatelessWidget {
  final Expense expense;

  const TransactionTile({super.key, required this.expense});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailsScreen(expense: expense),
          ),
        );
      },
      onLongPress: () => _showExpenseActions(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF120216),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    expense.category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
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
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF120216),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('dd MMM').format(expense.date),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showExpenseActions(BuildContext context) async {
    final selectedAction = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: const Text('Edit'),
                  onTap: () => Navigator.pop(sheetContext, 'edit'),
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline),
                  title: const Text('Delete'),
                  onTap: () => Navigator.pop(sheetContext, 'delete'),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!context.mounted || selectedAction == null) {
      return;
    }

    final appState = context.read<MyAppState>();
    final expenseIndex = appState.expenses.indexWhere(
      (e) => e.id == expense.id,
    );

    if (expenseIndex == -1) {
      return;
    }

    if (selectedAction == 'edit') {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditExpenseScreen(
            expense: appState.expenses[expenseIndex],
            index: expenseIndex,
          ),
        ),
      );
      return;
    }

    if (selectedAction == 'delete') {
      final shouldDelete = await _confirmDelete(context);
      if (shouldDelete && context.mounted) {
        final latestIndex = appState.expenses.indexWhere(
          (e) => e.id == expense.id,
        );
        if (latestIndex != -1) {
          appState.deleteExpense(appState.expenses[latestIndex]);
        }
      }
    }
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final decision = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete expense?'),
          content: Text('Delete "${expense.name}" permanently?'),
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

    return decision == true;
  }
}
