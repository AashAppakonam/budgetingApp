import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense_category.dart';
import '../models/transaction.dart';

enum SortOption { dateDesc, dateAsc, amountDesc, amountAsc }

class BudgetProvider extends ChangeNotifier {
  double _totalBudget = 0.0; // Default budget
  List<Transaction> _transactions = [];
  List<ExpenseCategory> _categories = [
    ExpenseCategory(id: '1', name: 'Food', emoji: '🍔', colorValue: Colors.orangeAccent.value),
    ExpenseCategory(id: '2', name: 'Transport', emoji: '🚗', colorValue: Colors.blueAccent.value),
    ExpenseCategory(id: '3', name: 'Entertainment', emoji: '🎬', colorValue: Colors.purpleAccent.value),
    ExpenseCategory(id: '4', name: 'Income', emoji: '💵', colorValue: Colors.greenAccent.value),
  ];
  
  bool _isDarkMode = true;
  String _currencySymbol = '\$';
  SortOption _currentSort = SortOption.dateDesc;
  String? _filterCategoryId;

  BudgetProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load Theme
    _isDarkMode = prefs.getBool('isDarkMode') ?? true;

    // Load Currency
    _currencySymbol = prefs.getString('currencySymbol') ?? '\$';

    // Load Budget
    _totalBudget = prefs.getDouble('totalBudget') ?? 0.0;

    // Load Categories
    final categoriesString = prefs.getString('categories');
    if (categoriesString != null) {
      final List decoded = json.decode(categoriesString);
      _categories = decoded.map((item) => ExpenseCategory.fromJson(item)).toList();
    }

    // Load Transactions
    final transactionsString = prefs.getString('transactions');
    if (transactionsString != null) {
      final List decoded = json.decode(transactionsString);
      _transactions = decoded.map((item) => Transaction.fromJson(item)).toList();
    }
    
    notifyListeners();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setBool('isDarkMode', _isDarkMode);
    await prefs.setString('currencySymbol', _currencySymbol);
    await prefs.setDouble('totalBudget', _totalBudget);
    
    final categoriesJson = json.encode(_categories.map((c) => c.toJson()).toList());
    await prefs.setString('categories', categoriesJson);
    
    final transactionsJson = json.encode(_transactions.map((t) => t.toJson()).toList());
    await prefs.setString('transactions', transactionsJson);
  }

  double get totalBudget => _totalBudget;
  bool get isDarkMode => _isDarkMode;
  String get currencySymbol => _currencySymbol;
  
  List<Transaction> get transactions {
    var list = _transactions.toList();

    // Apply Filter
    if (_filterCategoryId != null) {
      list = list.where((t) => t.category.id == _filterCategoryId).toList();
    }

    // Apply Sort
    list.sort((a, b) {
      switch (_currentSort) {
        case SortOption.dateDesc:
          return b.date.compareTo(a.date);
        case SortOption.dateAsc:
          return a.date.compareTo(b.date);
        case SortOption.amountDesc:
          return b.amount.compareTo(a.amount);
        case SortOption.amountAsc:
          return a.amount.compareTo(b.amount);
      }
    });

    return list;
  }
  
  List<ExpenseCategory> get categories => _categories;

  SortOption get currentSort => _currentSort;
  String? get filterCategoryId => _filterCategoryId;
  bool get hasActiveSortOrFilter => _currentSort != SortOption.dateDesc || _filterCategoryId != null;

  void setSortAndFilter(SortOption sort, String? categoryId) {
    _currentSort = sort;
    _filterCategoryId = categoryId;
    notifyListeners();
  }

  void clearSortAndFilter() {
    _currentSort = SortOption.dateDesc;
    _filterCategoryId = null;
    notifyListeners();
  }

  double get totalSpent => _transactions.where((t) => !t.isIncome).fold(0, (sum, item) => sum + item.amount);
  double get totalIncome => _transactions.where((t) => t.isIncome).fold(0, (sum, item) => sum + item.amount);
  double get remainingBudget => _totalBudget + totalIncome - totalSpent;

  Map<Color, double> get categorySpent {
    final Map<Color, double> map = {};
    for (var tx in _transactions.where((t) => !t.isIncome)) {
      final color = Color(tx.category.colorValue);
      map[color] = (map[color] ?? 0) + tx.amount;
    }
    return map;
  }

  List<Map<String, dynamic>> get categorySpentData {
    final Map<String, Map<String, dynamic>> map = {};
    for (var tx in _transactions.where((t) => !t.isIncome)) {
      final key = tx.category.id;
      if (!map.containsKey(key)) {
        map[key] = {
          'category': tx.category,
          'amount': 0.0,
        };
      }
      map[key]!['amount'] = (map[key]!['amount'] as double) + tx.amount;
    }
    return map.values.toList();
  }

  // For Autofill
  List<String> get previousNames => _transactions.map((t) => t.name).toSet().toList();

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _saveData();
    notifyListeners();
  }

  void setCurrency(String symbol) {
    _currencySymbol = symbol;
    _saveData();
    notifyListeners();
  }

  void setBudget(double budget) {
    _totalBudget = budget;
    _saveData();
    notifyListeners();
  }

  void addTransaction(Transaction transaction) {
    _transactions.add(transaction);
    _saveData();
    notifyListeners();
  }

  void addTransactions(List<Transaction> transactions) {
    _transactions.addAll(transactions);
    _saveData();
    notifyListeners();
  }

  void updateTransaction(Transaction updatedTransaction) {
    final index = _transactions.indexWhere((t) => t.id == updatedTransaction.id);
    if (index >= 0) {
      _transactions[index] = updatedTransaction;
      _saveData();
      notifyListeners();
    }
  }

  void deleteTransaction(String id) {
    _transactions.removeWhere((t) => t.id == id);
    _saveData();
    notifyListeners();
  }

  void addCategory(String name, String emoji) {
    final random = Random();
    final color = Color.fromARGB(
      255, 
      100 + random.nextInt(155), 
      100 + random.nextInt(155), 
      100 + random.nextInt(155)
    );
    
    _categories.add(ExpenseCategory(
      id: DateTime.now().toString(),
      name: name,
      emoji: emoji,
      colorValue: color.value,
    ));
    _saveData();
    notifyListeners();
  }

  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    _totalBudget = 0.0;
    _transactions = [];
    _categories = [
      ExpenseCategory(id: '1', name: 'Food', emoji: '🍔', colorValue: Colors.orangeAccent.value),
      ExpenseCategory(id: '2', name: 'Transport', emoji: '🚗', colorValue: Colors.blueAccent.value),
      ExpenseCategory(id: '3', name: 'Entertainment', emoji: '🎬', colorValue: Colors.purpleAccent.value),
      ExpenseCategory(id: '4', name: 'Income', emoji: '💵', colorValue: Colors.greenAccent.value),
    ];
    _currentSort = SortOption.dateDesc;
    _filterCategoryId = null;
    _currencySymbol = '\$';
    
    notifyListeners();
  }
}
