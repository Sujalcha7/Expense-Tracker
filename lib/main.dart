// import 'package:expense_tracker/screens/expenses_screen.dart';
import 'package:expense_tracker/screens/home_screen.dart';
import 'package:expense_tracker/state/app_state.dart';
import 'package:flutter/material.dart';
// You will create this file later for your main list of expenses.
// For now, it's a placeholder for the home screen of your app.
// import 'package:expense_tracker/screens/add_expense_screen.dart';
import 'package:provider/provider.dart'; // This import will be needed once you create home_screen.dart

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Expense Tracker',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          primaryColor: const Color.fromARGB(
            255,
            120,
            78,
            32,
          ), // You can customize your app's primary color
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: HomeScreen(),
      ),
      // Your main home screen where expenses will be listed
      // You can define routes here for easier navigation,
      // but for a beginner, direct Navigator.push is often simpler to start.
      // routes: {
      //   '/add-expense': (context) => AddExpenseScreen(),
      // },
    );
  }
}
