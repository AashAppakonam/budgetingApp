import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/budget_provider.dart';
import '../models/expense_category.dart';
import '../models/transaction.dart';

class AddEntryScreen extends StatefulWidget {
  const AddEntryScreen({super.key});

  @override
  State<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  final _amountController = TextEditingController();
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  ExpenseCategory? _selectedCategory;
  bool _isIncome = false;
  DateTime _selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final isDark = Provider.of<BudgetProvider>(context, listen: false).isDarkMode;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark 
              ? const ColorScheme.dark(
                  primary: Color(0xFF00E676),
                  onPrimary: Colors.black,
                  surface: Color(0xFF151515),
                  onSurface: Colors.white,
                )
              : const ColorScheme.light(
                  primary: Color(0xFF00E676),
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: Colors.black,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BudgetProvider>(context);
    final isDark = provider.isDarkMode;
    
    final textColor = isDark ? Colors.white : Colors.black;
    final hintColor = isDark ? Colors.white54 : Colors.black54;
    final dividerColor = isDark ? Colors.white24 : Colors.black26;
    final surfaceColor = isDark ? const Color(0xFF151515) : Colors.white;
    
    // Set default category if none selected
    _selectedCategory ??= provider.categories.first;

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Entry'),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Expense', style: TextStyle(color: hintColor, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(width: 10),
                Switch(
                  value: _isIncome,
                  activeColor: const Color(0xFF00E676),
                  inactiveThumbColor: Colors.redAccent,
                  inactiveTrackColor: Colors.redAccent.withOpacity(0.3),
                  onChanged: (val) {
                    setState(() {
                      _isIncome = val;
                    });
                  },
                ),
                const SizedBox(width: 10),
                Text('Income', style: TextStyle(color: hintColor, fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 40),
            Center(
              child: IntrinsicWidth(
                child: TextField(
                  controller: _amountController,
                  autofocus: true,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(fontSize: 64, fontWeight: FontWeight.w800, letterSpacing: -2.0, color: textColor),
                  decoration: InputDecoration(
                    prefixText: '${provider.currencySymbol} ',
                    prefixStyle: TextStyle(fontSize: 64, fontWeight: FontWeight.w800, letterSpacing: -2.0, color: hintColor),
                    border: InputBorder.none,
                    hintText: '0',
                    hintStyle: TextStyle(color: dividerColor),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            
            // Autofill for Names
            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text == '') {
                  return const Iterable<String>.empty();
                }
                return provider.previousNames.where((String option) {
                  return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                });
              },
              onSelected: (String selection) {
                _nameController.text = selection;
              },
              fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                // Keep sync with our local controller for manual input
                textEditingController.addListener(() {
                  _nameController.text = textEditingController.text;
                });
                return TextField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  style: TextStyle(fontSize: 18, color: textColor, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    labelText: 'Entry Name',
                    labelStyle: TextStyle(color: hintColor, fontSize: 14),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: dividerColor)),
                    focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF00E676))),
                  ),
                );
              },
            ),
            const SizedBox(height: 25),

            // Category Selector
            DropdownButtonFormField<ExpenseCategory>(
              value: _selectedCategory,
              icon: Icon(Icons.keyboard_arrow_down, color: hintColor),
              dropdownColor: surfaceColor,
              style: TextStyle(fontSize: 18, color: textColor, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                labelText: 'Category',
                labelStyle: TextStyle(color: hintColor, fontSize: 14),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: dividerColor)),
                focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF00E676))),
              ),
              items: provider.categories.map((cat) {
                return DropdownMenuItem(
                  value: cat,
                  child: Text('${cat.emoji}  ${cat.name}'),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  _selectedCategory = val;
                });
              },
            ),
            const SizedBox(height: 25),

            TextField(
              controller: _notesController,
              maxLines: null,
              style: TextStyle(fontSize: 16, color: textColor),
              decoration: InputDecoration(
                labelText: 'Additional Notes',
                labelStyle: TextStyle(color: hintColor, fontSize: 14),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: dividerColor)),
                focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF00E676))),
              ),
            ),
            const SizedBox(height: 25),

            // Date Picker Column
            GestureDetector(
              onTap: () => _selectDate(context),
              child: Container(
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: dividerColor)),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Date', style: TextStyle(color: hintColor, fontSize: 14)),
                    const SizedBox(height: 8),
                    Text(
                      DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate),
                      style: TextStyle(fontSize: 18, color: textColor, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 60),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E676),
                foregroundColor: Colors.black,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                if (_amountController.text.isEmpty || _nameController.text.isEmpty) return;
                
                provider.addTransaction(Transaction(
                  id: DateTime.now().toString(),
                  name: _nameController.text,
                  amount: double.parse(_amountController.text),
                  category: _selectedCategory!,
                  notes: _notesController.text,
                  date: _selectedDate,
                  isIncome: _isIncome,
                ));
                Navigator.pop(context);
              },
              child: const Text('SUBMIT', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: 1.0)),
            )
          ],
        ),
      ),
    );
  }
}
