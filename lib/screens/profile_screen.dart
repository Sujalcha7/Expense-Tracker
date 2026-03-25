import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/state/app_state.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();
    final expenses = appState.expenses;
    final totalSpent = expenses.fold(0.0, (sum, item) => sum + item.amount);
    final averageExpense = expenses.isEmpty
        ? 0.0
        : totalSpent / expenses.length;

    final favoriteCategory = _favoriteCategory(expenses);
    final firstExpenseDate = _firstExpenseDate(expenses);
    final latestExpenseDate = _latestExpenseDate(expenses);

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
              _buildProfileCard(),
              const SizedBox(height: 24),
              _buildSummaryCard(totalSpent, averageExpense),
              const SizedBox(height: 24),
              _buildInsightsCard(
                favoriteCategory: favoriteCategory,
                firstExpenseDate: firstExpenseDate,
                latestExpenseDate: latestExpenseDate,
                expenseCount: expenses.length,
              ),
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
          'Profile',
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
          child: const Icon(Icons.person_outline, color: Color(0xFF42224A)),
        ),
      ],
    );
  }

  Widget _buildProfileCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: Color(0xFF42224A),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 34),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'User',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF120216),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Expense Tracker Member',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(double totalSpent, double averageExpense) {
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
            'Account Summary',
            style: TextStyle(
              color: Color(0xFF8F659A),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          _summaryRow('Total spent', '\$${totalSpent.toStringAsFixed(2)}'),
          const SizedBox(height: 10),
          _summaryRow(
            'Average expense',
            '\$${averageExpense.toStringAsFixed(2)}',
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF8F659A), fontSize: 14),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildInsightsCard({
    required String favoriteCategory,
    required DateTime? firstExpenseDate,
    required DateTime? latestExpenseDate,
    required int expenseCount,
  }) {
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
          const Text(
            'Insights',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF120216),
            ),
          ),
          const SizedBox(height: 16),
          _insightRow(
            Icons.category_outlined,
            'Top category',
            favoriteCategory,
          ),
          const SizedBox(height: 14),
          _insightRow(
            Icons.calendar_month_outlined,
            'First expense',
            firstExpenseDate == null
                ? 'No expenses yet'
                : DateFormat('dd MMM yyyy').format(firstExpenseDate),
          ),
          const SizedBox(height: 14),
          _insightRow(
            Icons.update,
            'Latest expense',
            latestExpenseDate == null
                ? 'No expenses yet'
                : DateFormat('dd MMM yyyy').format(latestExpenseDate),
          ),
          const SizedBox(height: 14),
          _insightRow(Icons.receipt_long, 'Total receipts', '$expenseCount'),
        ],
      ),
    );
  }

  Widget _insightRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFF7F4F7),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: const Color(0xFF8F659A)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF120216),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _favoriteCategory(List<Expense> expenses) {
    if (expenses.isEmpty) {
      return 'No data yet';
    }

    final totals = <String, double>{};
    for (final expense in expenses) {
      totals[expense.category] =
          (totals[expense.category] ?? 0) + expense.amount;
    }

    final top = totals.entries.reduce((a, b) => a.value >= b.value ? a : b);
    return '${top.key} (\$${top.value.toStringAsFixed(2)})';
  }

  DateTime? _firstExpenseDate(List<Expense> expenses) {
    if (expenses.isEmpty) {
      return null;
    }
    return expenses.map((e) => e.date).reduce((a, b) => a.isBefore(b) ? a : b);
  }

  DateTime? _latestExpenseDate(List<Expense> expenses) {
    if (expenses.isEmpty) {
      return null;
    }
    return expenses.map((e) => e.date).reduce((a, b) => a.isAfter(b) ? a : b);
  }
}
