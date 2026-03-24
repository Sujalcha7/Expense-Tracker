import 'package:expense_tracker/screens/home_screen.dart';
import 'package:expense_tracker/state/app_state.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
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
          scaffoldBackgroundColor: const Color(0xFFF7F4F7),
          primaryColor: const Color(0xFF42224A),
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF42224A),
            secondary: Color(0xFFEF8767), // Orange Accent
            tertiary: Color(0xFF8F659A), // Light Purple Accent
            surface: Colors.white,
            onSurface: Color(0xFF120216), // Dark text
          ),
          textTheme: GoogleFonts.poppinsTextTheme(
            Theme.of(context).textTheme,
          ).apply(
            bodyColor: const Color(0xFF120216),
            displayColor: const Color(0xFF120216),
          ),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
