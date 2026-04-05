import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/budget_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showAddCategoryDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final emojiCtrl = TextEditingController();
    
    final isDark = Provider.of<BudgetProvider>(context, listen: false).isDarkMode;
    final textColor = isDark ? Colors.white : Colors.black;
    final hintColor = isDark ? Colors.white54 : Colors.black54;
    final dividerColor = isDark ? Colors.white24 : Colors.black26;
    final surfaceColor = isDark ? const Color(0xFF151515) : Colors.white;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('New Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: textColor)),
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
                Provider.of<BudgetProvider>(context, listen: false)
                    .addCategory(nameCtrl.text, emojiCtrl.text);
              }
              Navigator.pop(context);
            },
            child: const Text('Add', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showCurrencyDialog(BuildContext context) {
    final provider = Provider.of<BudgetProvider>(context, listen: false);
    final isDark = provider.isDarkMode;
    final surfaceColor = isDark ? const Color(0xFF151515) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;

    final currencies = [
      {'name': 'US Dollar', 'symbol': '\$'},
      {'name': 'Euro', 'symbol': '€'},
      {'name': 'British Pound', 'symbol': '£'},
      {'name': 'Japanese Yen', 'symbol': '¥'},
      {'name': 'Indian Rupee', 'symbol': '₹'},
    ];

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
                  trailing: Text(provider.currencySymbol, style: TextStyle(color: hintColor, fontSize: 16)),
                  onTap: () => _showCurrencyDialog(context),
                ),
                Divider(color: isDark ? Colors.white10 : Colors.black12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Text('DATA', style: TextStyle(color: hintColor, fontSize: 12, fontWeight: 
FontWeight.bold, letterSpacing: 1.0)),
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  title: Text('Export Data (CSV)', style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
                  trailing: Icon(Icons.download_rounded, color: hintColor),
                  onTap: () {},
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  title: Text('Add Custom Category', style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
                  trailing: const Icon(Icons.add_circle_outline, color: Color(0xFF00E676)),
                  onTap: () => _showAddCategoryDialog(context),
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