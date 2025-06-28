import 'package:expense_tracker/models/expense.dart';
import 'package:flutter/material.dart';

class MyAppState extends ChangeNotifier {
  final List<Expense> expenses = [];

  void addExpense(Expense expense) {
    expenses.add(expense);
    notifyListeners();
  }
}
