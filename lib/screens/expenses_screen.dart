// import 'package:expense_tracker/main.dart';
// import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/state/app_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ExpensesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return Scaffold(
      body: ListView(
        children: [
          Padding(padding: const EdgeInsets.all(8.0), child: Text('Expenses:')),
          for (var expense in appState.expenses)
            ListTile(
              title: Text(
                expense.name,
              ), // Replace 'title' with the actual property name
              subtitle: Text(
                'Rs ${expense.amount.toString()}',
              ), // Example for amount
            ),
        ],
      ),
    );
  }
}
