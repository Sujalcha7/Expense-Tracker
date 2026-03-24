import 'package:flutter/material.dart';

class Expense {
  final String id;
  final String name;
  final String description;
  final double amount;
  final DateTime date;
  final String category;

  Expense({
    required this.name,
    required this.description,
    required this.amount,
    required this.date,
    required this.category,
    String? id,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  IconData get categoryIcon {
    switch (category) {
      case 'Food & Drink':
        return Icons.fastfood; // Simulating the icon in details screen
      case 'Clothing & shoes':
        return Icons.checkroom; // Simulating the t-shirt icon
      case 'Fuel':
        return Icons.local_gas_station;
      case 'Clothing':
        return Icons.checkroom;
      case 'Electronics':
        return Icons.phone_iphone;
      case 'Transport':
        return Icons.directions_car;
      case 'Shoes':
        return Icons.directions_run;
      default:
        return Icons.category;
    }
  }

  @override
  String toString() {
    return 'Expense(name: $name, amount: $amount, category: $category, date: $date)';
  }
}
