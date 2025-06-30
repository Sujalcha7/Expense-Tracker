// import 'package:expense_tracker/main.dart';
// import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/screens/edit_expense_screen.dart';
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
          for (var i = 0; i < appState.expenses.length; i++)
            ListTile(
              title: Text(
                appState.expenses[i].name,
              ), // Replace 'title' with the actual property name
              subtitle: Text('Rs ${appState.expenses[i].amount.toString()}'),
              onLongPress: () {
                longPresssOptions(context, appState.expenses[i], i, appState);
              }, // Example for amount
            ),
        ],
      ),
    );
  }

  Future<dynamic> longPresssOptions(
    BuildContext context,
    Expense expense,
    int index,
    MyAppState appState,
  ) {
    return showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        EditExpenseScreen(expense: expense, index: index),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.delete),
              title: Text('Delete'),
              onTap: () {
                Navigator.pop(context);
                showAlertDialog(context, expense, appState);
              },
            ),
          ],
        );
      },
    );
  }
}

void showAlertDialog(
  BuildContext context,
  Expense expense,
  MyAppState appState,
) {
  // set up the buttons
  Widget deleteButton = ElevatedButton(
    child: Text("Delete"),
    onPressed: () {
      appState.deleteExpense(expense);
      Navigator.of(context).pop();

      // Close the dialog
    },
  );
  Widget cancelButton = ElevatedButton(
    child: Text("Cancel"),
    onPressed: () {
      Navigator.of(context).pop();
      Navigator.pop(context); // Close the dialog
    },
  );
  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("Delete Expense?"),
    content: Text("Are you sure you want to delete this expense?"),
    actions: [cancelButton, deleteButton],
  );
  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
