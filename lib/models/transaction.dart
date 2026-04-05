import 'expense_category.dart';

class Transaction {
  final String id;
  final String name;
  final double amount;
  final ExpenseCategory category;
  final String notes;
  final DateTime date;
  final bool isIncome;

  Transaction({
    required this.id,
    required this.name,
    required this.amount,
    required this.category,
    this.notes = '',
    required this.date,
    this.isIncome = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'amount': amount,
        'category': category.toJson(),
        'notes': notes,
        'date': date.toIso8601String(),
        'isIncome': isIncome,
      };

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        id: json['id'],
        name: json['name'],
        amount: json['amount'],
        category: ExpenseCategory.fromJson(json['category']),
        notes: json['notes'],
        date: DateTime.parse(json['date']),
        isIncome: json['isIncome'] ?? false,
      );
}
