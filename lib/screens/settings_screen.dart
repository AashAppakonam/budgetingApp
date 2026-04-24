import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import '../providers/budget_provider.dart';
import '../models/transaction.dart';
import '../models/expense_category.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showAddCategoryDialog(BuildContext context, {ExpenseCategory? existingCategory}) {
    final nameCtrl = TextEditingController(text: existingCategory?.name ?? '');
    final emojiCtrl = TextEditingController(text: existingCategory?.emoji ?? '');
    
    final isDark = Provider.of<BudgetProvider>(context, listen: false).isDarkMode;
    final textColor = isDark ? Colors.white : Colors.black;
    final hintColor = isDark ? Colors.white54 : Colors.black54;
    final dividerColor = isDark ? Colors.white24 : Colors.black26;
    final surfaceColor = isDark ? const Color(0xFF151515) : Colors.white;

    Color selectedColor = existingCategory != null 
        ? Color(existingCategory.colorValue) 
        : const Color(0xFF00E676);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: surfaceColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: Text(existingCategory == null ? 'New Category' : 'Edit Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: textColor)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: emojiCtrl,
                  style: TextStyle(fontSize: 18, color: textColor),
                  decoration: InputDecoration(
                    labelText: 'Emoji (e.g. ☕)',
                    labelStyle: TextStyle(color: hintColor),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: dividerColor)),
                    focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF00E676))),
                  )
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: nameCtrl,
                  style: TextStyle(fontSize: 18, color: textColor),
                  decoration: InputDecoration(
                    labelText: 'Category Name',
                    labelStyle: TextStyle(color: hintColor),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: dividerColor)),
                    focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF00E676))),
                  )
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Text('Color', style: TextStyle(color: hintColor, fontSize: 16)),
                    const SizedBox(width: 15),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            Color tempColor = selectedColor;
                            return AlertDialog(
                              backgroundColor: surfaceColor,
                              title: Text('Pick a color', style: TextStyle(color: textColor)),
                              content: SingleChildScrollView(
                                child: BlockPicker(
                                  pickerColor: selectedColor,
                                  onColorChanged: (color) => tempColor = color,
                                ),
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
                          border: Border.all(color: dividerColor, width: 1),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: TextStyle(color: hintColor))),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E676),
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  if (nameCtrl.text.isNotEmpty && emojiCtrl.text.isNotEmpty) {
                    final provider = Provider.of<BudgetProvider>(context, listen: false);
                    if (existingCategory != null) {
                      provider.updateCategory(ExpenseCategory(
                        id: existingCategory.id,
                        name: nameCtrl.text,
                        emoji: emojiCtrl.text,
                        colorValue: selectedColor.value,
                      ));
                    } else {
                      provider.addCategory(nameCtrl.text, emojiCtrl.text, selectedColor);
                    }
                  }
                  Navigator.pop(context);
                },
                child: Text(existingCategory == null ? 'Add' : 'Save', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }

  static const defaultCurrencies = [
    {'name': 'US Dollar', 'symbol': '\$'},
    {'name': 'Euro', 'symbol': '€'},
    {'name': 'British Pound', 'symbol': '£'},
    {'name': 'Japanese Yen', 'symbol': '¥'},
    {'name': 'Indian Rupee', 'symbol': '₹'},
  ];

  void _showCurrencyDialog(BuildContext context) {
    final provider = Provider.of<BudgetProvider>(context, listen: false);
    final isDark = provider.isDarkMode;
    final surfaceColor = isDark ? const Color(0xFF151515) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;

    final currencies = defaultCurrencies;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('Select Currency', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: textColor)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: currencies.length,
            itemBuilder: (context, index) {
              final currency = currencies[index];
              return ListTile(
                title: Text('${currency['name']} (${currency['symbol']})', style: TextStyle(color: textColor)),
                onTap: () {
                  provider.setCurrency(currency['symbol']!);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _exportCSV(BuildContext context, BudgetProvider provider) async {
    try {
      // Create CSV Header
      StringBuffer csvString = StringBuffer();
      csvString.writeln('Date,Type,Amount,Category,Name,Notes');

      // Add Data
      for (var tx in provider.transactions) {
        final dateStr = DateFormat('yyyy-MM-dd').format(tx.date);
        final typeStr = tx.isIncome ? 'Income' : 'Expense';
        final amountStr = tx.amount.toStringAsFixed(2);
        
        // Escape quotes to prevent CSV breaking
        final categoryStr = tx.category.name.replaceAll('\"', '\"\"');
        final nameStr = tx.name.replaceAll('\"', '\"\"');
        final notesStr = tx.notes.replaceAll('\"', '\"\"');

        csvString.writeln('$dateStr,$typeStr,$amountStr,"${tx.category.emoji} $categoryStr","$nameStr","$notesStr"');
      }

      final Uint8List fileBytes = Uint8List.fromList(utf8.encode(csvString.toString()));

      final String? selectedDirectory = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Budget Export',
        fileName: 'budget_export.csv',
        type: FileType.custom,
        allowedExtensions: ['csv'],
        bytes: fileBytes,
      );

      if (selectedDirectory != null) {
        // file_picker saveFile with `bytes` already writes the file for us on most platforms,
        // but just to be sure we can check if it exists or write it if it doesn't.
        final file = File(selectedDirectory);
        if (!await file.exists()) {
           await file.writeAsBytes(fileBytes);
        }
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('File saved successfully!'),
              backgroundColor: Color(0xFF00E676),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to export data: $e'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  void _importCSV(BuildContext context, BudgetProvider provider) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null && result.files.single.path != null) {
        final File file = File(result.files.single.path!);
        final String csvString = await file.readAsString();
        
        List<List<dynamic>> rowsAsListOfValues = csv.decode(csvString);
        
        if (rowsAsListOfValues.length <= 1) return;

        var dataRows = rowsAsListOfValues.skip(1);
        List<Transaction> importedTxs = [];
        
        for (var row in dataRows) {
          if (row.length < 6) continue;
          
          final String dateStr = row[0].toString();
          final String typeStr = row[1].toString();
          final double amount = double.tryParse(row[2].toString()) ?? 0.0;
          final String rawCategory = row[3].toString();
          final String name = row[4].toString();
          final String notes = row[5].toString();

          // Try to extract emoji
          String catEmoji = '📦';
          String catName = 'Imported';
          
          if (rawCategory.isNotEmpty) {
            // Very naive split for our format "%emoji %name"
            if (rawCategory.contains(' ')) {
              final split = rawCategory.split(' ');
              catEmoji = split.first;
              catName = split.skip(1).join(' ');
            } else {
              catName = rawCategory;
            }
          }

          // Match existing category
          ExpenseCategory? category;
          try {
            category = provider.categories.firstWhere((c) => c.name.toLowerCase() == catName.toLowerCase());
          } catch (_) {}

          if (category == null) {
            provider.addCategory(catName, catEmoji);
            category = provider.categories.last;
          }

          importedTxs.add(Transaction(
            id: '\${DateTime.now().millisecondsSinceEpoch}_\${importedTxs.length}',
            name: name,
            amount: amount,
            category: category,
            notes: notes,
            date: DateTime.tryParse(dateStr) ?? DateTime.now(),
            isIncome: typeStr.toLowerCase() == 'income'
          ));
        }

        if (importedTxs.isNotEmpty) {
          provider.addTransactions(importedTxs);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Successfully imported \${importedTxs.length} transactions!'),
                backgroundColor: const Color(0xFF00E676),
                duration: const Duration(seconds: 3),
              ),
            );
          }
        } else if (context.mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No valid transactions found in CSV.'), backgroundColor: Colors.orangeAccent),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to import data: $e'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BudgetProvider>(context);
    final isDark = provider.isDarkMode;
    
    final textColor = isDark ? Colors.white : Colors.black;
    final hintColor = isDark ? Colors.white54 : Colors.black54;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 20),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Text('PREFERENCES', style: TextStyle(color: hintColor, fontSize: 12, fontWeight: 
FontWeight.bold, letterSpacing: 1.0)),
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  title: Text('Dark Mode', style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
                  trailing: Switch(
                    value: isDark,
                    activeColor: const Color(0xFF00E676),
                    onChanged: (val) {
                      provider.toggleTheme();
                    },
                  ),
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  title: Text('Currency', style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
                  trailing: Text(
                    () {
                      final match = defaultCurrencies.cast<Map<String, String>>().firstWhere(
                        (c) => c['symbol'] == provider.currencySymbol, 
                        orElse: () => {'name': 'Unknown', 'symbol': provider.currencySymbol},
                      );
                      return '${match['name']} (${match['symbol']})';
                    }(),
                    style: TextStyle(color: hintColor, fontSize: 16),
                  ),
                  onTap: () => _showCurrencyDialog(context),
                ),
                Divider(color: isDark ? Colors.white10 : Colors.black12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Text('DATA', style: TextStyle(color: hintColor, fontSize: 12, fontWeight: 
FontWeight.bold, letterSpacing: 1.0)),
                ),
                ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 24),
                  title: Row(
                    children: [
                      Text('Manage Categories', style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, color: Color(0xFF00E676)),
                        onPressed: () => _showAddCategoryDialog(context),
                      ),
                    ],
                  ),
                  iconColor: const Color(0xFF00E676),
                  collapsedIconColor: hintColor,
                  children: [
                    ...provider.categories.map((cat) => ListTile(
                      contentPadding: const EdgeInsets.only(left: 40, right: 24),
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Color(cat.colorValue).withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(cat.emoji, style: const TextStyle(fontSize: 18, )),
                      ),
                      title: Text(cat.name, style: TextStyle(color: textColor)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: hintColor, size: 20),
                            onPressed: () => _showAddCategoryDialog(context, existingCategory: cat),
                          ),
                          if (provider.categories.length > 1)
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    backgroundColor: provider.isDarkMode ? const Color(0xFF151515) : Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    title: Text('Delete Category?', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                                    content: Text('Transactions in this category will be reassigned. Are you sure?', style: TextStyle(color: hintColor)),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: Text('Cancel', style: TextStyle(color: hintColor)),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.redAccent,
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                        ),
                                        onPressed: () => Navigator.pop(context, true),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  provider.deleteCategory(cat.id);
                                }
                              },
                            ),
                        ],
                      ),
                    )).toList(),
                    ListTile(
                      contentPadding: const EdgeInsets.only(left: 40, right: 24),
                      leading: const Icon(Icons.add_circle_outline, color: Color(0xFF00E676)),
                      title: const Text('Add New Category', style: TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.w600)),
                      onTap: () => _showAddCategoryDialog(context),
                    ),
                  ],
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  title: Text('Export Data (CSV)', style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
                  trailing: Icon(Icons.download_rounded, color: hintColor),
                  onTap: () => _exportCSV(context, provider),
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  title: Text('Import Data (CSV)', style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
                  trailing: Icon(Icons.upload_rounded, color: hintColor),
                  onTap: () => _importCSV(context, provider),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            child: SafeArea(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent.withOpacity(0.1),
                  foregroundColor: Colors.redAccent,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Colors.redAccent, width: 2),
                  ),
                ),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: provider.isDarkMode ? const Color(0xFF151515) : Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      title: const Text('Reset Everything?', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
                      content: Text('Are you completely sure you want to delete all saved data? This action cannot be reversed.', style: TextStyle(color: provider.isDarkMode ? Colors.white70 : Colors.black87)),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text('Cancel', style: TextStyle(color: provider.isDarkMode ? Colors.white54 : Colors.black54)),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Reset', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true && context.mounted) {
                    await Provider.of<BudgetProvider>(context, listen: false).clearAllData();
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  }
                },
                child: const Text('CLEAR AND RESET DATA', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: 1.0)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}