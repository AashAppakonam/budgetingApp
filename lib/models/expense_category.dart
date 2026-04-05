import 'package:flutter/material.dart';
import 'dart:math';

class ExpenseCategory {
  final String id;
  final String name;
  final String emoji;
  final int colorValue;

  ExpenseCategory({
    required this.id,
    required this.name,
    required this.emoji,
    required this.colorValue,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'emoji': emoji,
        'colorValue': colorValue,
      };

  factory ExpenseCategory.fromJson(Map<String, dynamic> json) {
    int colorVal = json['colorValue'] ?? Colors.blueAccent.value;
    // Fallback for older data without colorValue: give standard colors based on id/name
    if (json['colorValue'] == null) {
      if (json['name'] == 'Food') colorVal = Colors.orangeAccent.value;
      else if (json['name'] == 'Transport') colorVal = Colors.blueAccent.value;
      else if (json['name'] == 'Entertainment') colorVal = Colors.purpleAccent.value;
      else if (json['name'] == 'Income') colorVal = Colors.greenAccent.value;
      else {
        final random = Random(json['id'].hashCode);
        colorVal = Color.fromARGB(255, 100 + random.nextInt(155), 100 + random.nextInt(155), 100 + random.nextInt(155)).value;
      }
    }
    return ExpenseCategory(
      id: json['id'],
      name: json['name'],
      emoji: json['emoji'],
      colorValue: colorVal,
    );
  }
}
