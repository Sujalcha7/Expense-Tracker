import 'package:expense_tracker/screens/add_expense_screen.dart';
import 'package:expense_tracker/screens/expenses_screen.dart';
import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = AddExpenseScreen();
      case 1:
        page = ExpensesScreen();
      default:
        throw UnimplementedError();
    }
    return Scaffold(
      body: Column(
        children: [
          Expanded(child: page),
          BottomNavigationBar(
            items: [
              BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Add'),
              BottomNavigationBarItem(
                icon: Icon(Icons.money),
                label: 'Expenses',
              ),
            ],
            currentIndex: selectedIndex,
            onTap: (value) {
              setState(() {
                selectedIndex = value;
              });
            },
          ),
        ],
      ),
    );
  }
}
