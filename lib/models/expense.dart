class Expense {
  final String name;
  final String description;
  final double amount;

  Expense({
    required this.name,
    required this.description,
    required this.amount,
  });

  @override
  String toString() {
    return 'Expense(name: $name, description: $description, amount: $amount)';
  }
}
