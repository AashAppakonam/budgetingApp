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
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF00E676),
              onPrimary: Colors.black,
              surface: Color(0xFF151515),
              onSurface: Colors.white,
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
                const Text('Expense', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold, fontSize: 16)),
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
                const Text('Income', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 40),
            Center(
              child: IntrinsicWidth(
                child: TextField(
                  controller: _amountController,
                  autofocus: true,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(fontSize: 64, fontWeight: FontWeight.w800, letterSpacing: -2.0, color: Colors.white),
                  decoration: const InputDecoration(
                    prefixText: '\$ ',
                    prefixStyle: TextStyle(fontSize: 64, fontWeight: FontWeight.w800, letterSpacing: -2.0, color: Colors.white54),
                    border: InputBorder.none,
                    hintText: '0',
                    hintStyle: TextStyle(color: Colors.white24),
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
                  style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w600),
                  decoration: const InputDecoration(
                    labelText: 'Entry Name',
                    labelStyle: TextStyle(color: Colors.white54, fontSize: 14),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF00E676))),
                  ),
                );
              },
            ),
            const SizedBox(height: 25),

            // Category Selector
            DropdownButtonFormField<ExpenseCategory>(
              value: _selectedCategory,
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white54),
              dropdownColor: const Color(0xFF151515),
              style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w600),
              decoration: const InputDecoration(
                labelText: 'Category',
                labelStyle: TextStyle(color: Colors.white54, fontSize: 14),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF00E676))),
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
              style: const TextStyle(fontSize: 16, color: Colors.white70),
              decoration: const InputDecoration(
                labelText: 'Additional Notes',
                labelStyle: TextStyle(color: Colors.white54, fontSize: 14),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF00E676))),
              ),
            ),
            const SizedBox(height: 25),

            // Date Picker Column
            GestureDetector(
              onTap: () => _selectDate(context),
              child: Container(
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.white24)),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Date', style: TextStyle(color: Colors.white54, fontSize: 14)),
                    const SizedBox(height: 8),
                    Text(
                      DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate),
                      style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w600),
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
