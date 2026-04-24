import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:intl/intl.dart';
import '../providers/budget_provider.dart';
import '../models/expense_category.dart';
import '../models/transaction.dart';

class AddEntryScreen extends StatefulWidget {
  final Transaction? existingTransaction;

  const AddEntryScreen({super.key, this.existingTransaction});

  @override
  State<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  late TextEditingController _amountController;
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  ExpenseCategory? _selectedCategory;
  bool _isIncome = false;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final ext = widget.existingTransaction;
    _amountController = TextEditingController(
      text: ext?.amount.toString() ?? '',
    );
    if (ext != null) {
      _nameController.text = ext.name;
      _notesController.text = ext.notes;
      _selectedCategory = ext.category;
      _isIncome = ext.isIncome;
      _selectedDate = ext.date;
    } else {
      _selectedDate = DateTime.now();
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final isDark = Provider.of<BudgetProvider>(
      context,
      listen: false,
    ).isDarkMode;
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

  void _showAddCategoryDialog(BuildContext context, BudgetProvider provider) {
    final nameCtrl = TextEditingController();
    final emojiCtrl = TextEditingController(text: '🛒');
    final isDark = provider.isDarkMode;
    final textColor = isDark ? Colors.white : Colors.black;
    final hintColor = isDark ? Colors.white54 : Colors.black54;
    final surfaceColor = isDark ? const Color(0xFF151515) : Colors.white;

    Color selectedColor = const Color(0xFF00E676);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: surfaceColor,
              title: Text(
                'New Category',
                style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: emojiCtrl,
                    maxLength: 1,
                    style: TextStyle(fontSize: 24, color: textColor),
                    decoration: InputDecoration(
                      labelText: 'Emoji',
                      labelStyle: TextStyle(color: hintColor),
                      counterText: '',
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: hintColor),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF00E676)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: nameCtrl,
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      labelText: 'Category Name',
                      labelStyle: TextStyle(color: hintColor),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: hintColor),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF00E676)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Text(
                        'Color',
                        style: TextStyle(color: hintColor, fontSize: 16),
                      ),
                      const SizedBox(width: 15),
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              Color tempColor = selectedColor;
                              return AlertDialog(
                                backgroundColor: surfaceColor,
                                title: Text(
                                  'Pick a color',
                                  style: TextStyle(color: textColor),
                                ),
                                content: SingleChildScrollView(
                                  child: BlockPicker(
                                    pickerColor: selectedColor,
                                    onColorChanged: (color) =>
                                        tempColor = color,
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text(
                                      'Cancel',
                                      style: TextStyle(color: hintColor),
                                    ),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF00E676),
                                      foregroundColor: Colors.black,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        selectedColor = tempColor;
                                      });
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Select'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: selectedColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: hintColor, width: 1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel', style: TextStyle(color: hintColor)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00E676),
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () {
                    if (nameCtrl.text.isNotEmpty && emojiCtrl.text.isNotEmpty) {
                      provider.addCategory(
                        nameCtrl.text,
                        emojiCtrl.text,
                        selectedColor,
                      );
                      setState(() {
                        _selectedCategory = provider.categories.last;
                      });
                      // Only pop the inner dialog if it's mounted, we use Navigator.pop
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
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
        title: Text(
          widget.existingTransaction == null ? 'New Entry' : 'Edit Entry',
        ),
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
                Text(
                  'Expense',
                  style: TextStyle(
                    color: hintColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
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
                Text(
                  'Income',
                  style: TextStyle(
                    color: hintColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Center(
              child: IntrinsicWidth(
                child: TextField(
                  controller: _amountController,
                  autofocus: true,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -2.0,
                    color: textColor,
                  ),
                  decoration: InputDecoration(
                    prefixText: '${provider.currencySymbol} ',
                    prefixStyle: TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -2.0,
                      color: hintColor,
                    ),
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
              initialValue: TextEditingValue(
                text: widget.existingTransaction?.name ?? '',
              ),
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text == '') {
                  return const Iterable<String>.empty();
                }
                return provider.previousNames.where((String option) {
                  return option.toLowerCase().contains(
                    textEditingValue.text.toLowerCase(),
                  );
                });
              },
              onSelected: (String selection) {
                _nameController.text = selection;
              },
              fieldViewBuilder:
                  (
                    context,
                    textEditingController,
                    focusNode,
                    onFieldSubmitted,
                  ) {
                    // Keep sync with our local controller for manual input
                    textEditingController.addListener(() {
                      _nameController.text = textEditingController.text;
                    });
                    return TextField(
                      controller: textEditingController,
                      focusNode: focusNode,
                      style: TextStyle(
                        fontSize: 18,
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Entry Name',
                        labelStyle: TextStyle(color: hintColor, fontSize: 14),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: dividerColor),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF00E676)),
                        ),
                      ),
                    );
                  },
            ),
            const SizedBox(height: 25),

            // Category Selector
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: DropdownButtonFormField<ExpenseCategory>(
                    value: _selectedCategory,
                    icon: Icon(Icons.keyboard_arrow_down, color: hintColor),
                    dropdownColor: surfaceColor,
                    style: TextStyle(
                      fontSize: 18,
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Category',
                      labelStyle: TextStyle(color: hintColor, fontSize: 14),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: dividerColor),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF00E676)),
                      ),
                    ),
                    isExpanded: true,
                    items: provider.categories.map((cat) {
                      return DropdownMenuItem(
                        value: cat,
                        child: Text(
                          '${cat.emoji}  ${cat.name}',
                          style: const TextStyle(),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedCategory = val;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  margin: const EdgeInsets.only(bottom: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E676).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add, color: Color(0xFF00E676)),
                    onPressed: () => _showAddCategoryDialog(context, provider),
                    tooltip: 'Add new category',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),

            TextField(
              controller: _notesController,
              maxLines: null,
              style: TextStyle(fontSize: 16, color: textColor),
              decoration: InputDecoration(
                labelText: 'Additional Notes',
                labelStyle: TextStyle(color: hintColor, fontSize: 14),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: dividerColor),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF00E676)),
                ),
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
                    Text(
                      'Date',
                      style: TextStyle(color: hintColor, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate),
                      style: TextStyle(
                        fontSize: 18,
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
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
                final amountText = _amountController.text.trim();
                final nameText = _nameController.text.trim();

                if (amountText.isEmpty || nameText.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter both an amount and a name.'),
                      backgroundColor: Colors.redAccent,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }

                final amount = double.tryParse(amountText);
                if (amount == null || amount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please enter a valid amount greater than 0.',
                      ),
                      backgroundColor: Colors.redAccent,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }

                final newTx = Transaction(
                  id:
                      widget.existingTransaction?.id ??
                      DateTime.now().toString(),
                  name: nameText,
                  amount: amount,
                  category: _selectedCategory!,
                  notes: _notesController.text,
                  date: _selectedDate,
                  isIncome: _isIncome,
                );

                if (widget.existingTransaction != null) {
                  provider.updateTransaction(newTx);
                } else {
                  provider.addTransaction(newTx);
                }

                Navigator.pop(context);
              },
              child: Text(
                widget.existingTransaction == null ? 'SUBMIT' : 'UPDATE',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            if (widget.existingTransaction != null) ...[
              const SizedBox(height: 16),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: surfaceColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      title: Text(
                        'Delete Entry?',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      content: Text(
                        'Are you sure you want to remove this transaction?',
                        style: TextStyle(color: hintColor),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(
                            'Cancel',
                            style: TextStyle(color: hintColor),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text(
                            'Delete',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    provider.deleteTransaction(widget.existingTransaction!.id);
                    if (context.mounted) Navigator.pop(context);
                  }
                },
                child: const Text(
                  'DELETE ENTRY',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
