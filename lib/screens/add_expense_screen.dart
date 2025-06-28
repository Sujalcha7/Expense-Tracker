import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/state/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class AddExpenseScreen extends StatelessWidget {
  AddExpenseScreen({super.key});
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    final screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
      fontSize: 27,
    );
    IconData icon = Icons.save;
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Add Expenses', style: style)),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Text("This is Add expense screen."),
            SizedBox(
              width: screenWidth * 0.9,
              child: Column(
                children: [
                  TextField(
                    controller: _amountController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Expense Amount',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Expense Name',
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Expense Description',
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () {
                      final name = _nameController.text;
                      final description = _descriptionController.text;
                      final amountText = _amountController.text;
                      final amount = double.tryParse(amountText) ?? 0.0;

                      final expense = Expense(
                        name: name,
                        description: description,
                        amount: amount,
                      );
                      // print(expense);
                      appState.addExpense(expense);
                      _nameController.clear();
                      _descriptionController.clear();
                      _amountController.clear();
                    },
                    icon: Icon(icon),
                    label: Text('Add'),
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
