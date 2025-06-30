import 'package:expense_tracker/models/expense.dart';
import 'package:flutter/material.dart';

class MyAppState extends ChangeNotifier {
  final List<Expense> expenses = [];

  void addExpense(Expense expense) {
    expenses.add(expense);
    notifyListeners();
  }

  void deleteExpense(Expense expense) {
    expenses.remove(expense);
    notifyListeners();
  }

  void editExpense(int index, Expense newExpense) {
    expenses[index] = newExpense;
    notifyListeners();
  }
}
