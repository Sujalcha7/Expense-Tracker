import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/screens/details_screen.dart';
import 'package:expense_tracker/screens/edit_expense_screen.dart';
import 'package:expense_tracker/state/app_state.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ReceiptScreen extends StatefulWidget {
  const ReceiptScreen({super.key});

  @override
  State<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();
    final expenses = List<Expense>.from(appState.expenses)
      ..sort((a, b) => b.date.compareTo(a.date));
    final filteredExpenses = _filterExpenses(expenses);

    final totalAmount = filteredExpenses.fold(0.0, (sum, item) => sum + item.amount);
    final missingDetailsCount = filteredExpenses
      .where((expense) => expense.description.trim().isEmpty)
      .length;
    final largestAmount = filteredExpenses.isEmpty
        ? 0.0
        : filteredExpenses
              .map((e) => e.amount)
              .reduce((a, b) => a > b ? a : b);

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
              _buildSearchField(),
              const SizedBox(height: 14),
              _buildFilterChips(),
              const SizedBox(height: 22),
              _buildSummaryCard(
                totalAmount,
                filteredExpenses.length,
                largestAmount,
                missingDetailsCount,
              ),
              const SizedBox(height: 24),
              _buildNeedsAttention(filteredExpenses),
              const SizedBox(height: 26),
              _buildReceiptList(filteredExpenses),
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
          'Receipts',
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
          child: const Icon(Icons.receipt_long, color: Color(0xFF42224A)),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search, color: Color(0xFF8F659A)),
        hintText: 'Search by name or category',
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'This Month', 'Last 30 Days'];
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = filter == _selectedFilter;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedFilter = filter;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF8F659A) : Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Text(
                filter,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF120216),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemCount: filters.length,
      ),
    );
  }

  Widget _buildSummaryCard(
    double totalAmount,
    int receiptCount,
    double largestAmount,
    int missingDetailsCount,
  ) {
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
            'All Receipts',
            style: TextStyle(
              color: Color(0xFF8F659A),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '\$${totalAmount.toStringAsFixed(2)}',
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
                Icons.confirmation_num_outlined,
                color: Color(0xFF8F659A),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                '$receiptCount stored receipts',
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
              const Icon(
                Icons.trending_up,
                color: Color(0xFF8F659A),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Largest receipt: \$${largestAmount.toStringAsFixed(2)}',
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
              const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFF8F659A),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                '$missingDetailsCount receipts missing details',
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

  Widget _buildNeedsAttention(List<Expense> expenses) {
    final flagged = expenses.where((expense) {
      final missingDescription = expense.description.trim().isEmpty;
      final highValue = expense.amount >= 500;
      return missingDescription || highValue;
    }).toList();

    if (flagged.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Needs Attention',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...flagged.take(3).map((expense) {
          final reason = expense.description.trim().isEmpty
              ? 'Missing description'
              : 'High-value receipt';
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expense.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF120216),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        reason,
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => _onReceiptAction(expense, 'edit'),
                  child: const Text('Review'),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildReceiptList(List<Expense> expenses) {
    if (expenses.isEmpty) {
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
          'No receipts yet. Add an expense to generate your first receipt.',
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Receipt History',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        ..._buildGroupedReceipts(expenses),
      ],
    );
  }

  List<Widget> _buildGroupedReceipts(List<Expense> expenses) {
    final Map<String, List<Expense>> grouped = {};
    for (final expense in expenses) {
      final key = DateFormat('MMMM yyyy').format(expense.date);
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(expense);
    }

    final widgets = <Widget>[];
    for (final entry in grouped.entries) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            entry.key,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
      widgets.addAll(entry.value.map(_buildReceiptTile));
      widgets.add(const SizedBox(height: 8));
    }

    return widgets;
  }

  Widget _buildReceiptTile(Expense expense) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DetailsScreen(expense: expense)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFFF7F4F7),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(expense.categoryIcon, color: const Color(0xFF8F659A)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF120216),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${expense.category} • ${DateFormat('dd MMM yyyy').format(expense.date)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${expense.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF120216),
                  ),
                ),
                PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.more_vert, size: 18, color: Colors.grey),
                  onSelected: (value) => _onReceiptAction(expense, value),
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Expense> _filterExpenses(List<Expense> source) {
    final query = _searchController.text.trim().toLowerCase();
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));

    return source.where((expense) {
      final inFilter = switch (_selectedFilter) {
        'This Month' => expense.date.year == now.year && expense.date.month == now.month,
        'Last 30 Days' => !expense.date.isBefore(thirtyDaysAgo),
        _ => true,
      };

      if (!inFilter) {
        return false;
      }

      if (query.isEmpty) {
        return true;
      }

      return expense.name.toLowerCase().contains(query) ||
          expense.category.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> _onReceiptAction(Expense expense, String action) async {
    final appState = context.read<MyAppState>();
    final expenseIndex = appState.expenses.indexWhere((e) => e.id == expense.id);
    if (expenseIndex == -1) {
      return;
    }

    if (action == 'edit') {
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

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete receipt?'),
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

    if (shouldDelete == true && mounted) {
      final latestIndex = appState.expenses.indexWhere((e) => e.id == expense.id);
      if (latestIndex != -1) {
        appState.deleteExpense(appState.expenses[latestIndex]);
      }
    }
  }
}
