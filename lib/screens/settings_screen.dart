import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/budget_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showAddCategoryDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final emojiCtrl = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF151515),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('New Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emojiCtrl,
              style: const TextStyle(fontSize: 18, color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Emoji (e.g. ☕)',
                labelStyle: TextStyle(color: Colors.white54),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF00E676))),
              )
            ),
            const SizedBox(height: 10),
            TextField(
              controller: nameCtrl,
              style: const TextStyle(fontSize: 18, color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Category Name',
                labelStyle: TextStyle(color: Colors.white54),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF00E676))),
              )
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
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

  @override
  Widget build(BuildContext context) {
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
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Text('PREFERENCES', style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: 
FontWeight.bold, letterSpacing: 1.0)),
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  title: const Text('Dark Mode', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  trailing: const Icon(Icons.check_circle, color: Color(0xFF00E676)),
                  onTap: () {},
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  title: const Text('Currency', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  trailing: const Text('USD (\$)', style: TextStyle(color: Colors.white54, fontSize: 14)),
                  onTap: () {},
                ),
                const Divider(color: Colors.white10),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Text('DATA', style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: 
FontWeight.bold, letterSpacing: 1.0)),
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  title: const Text('Export Data (CSV)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  trailing: const Icon(Icons.download_rounded, color: Colors.white54),
                  onTap: () {},
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  title: const Text('Add Custom Category', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
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
                      backgroundColor: const Color(0xFF151515),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      title: const Text('Reset Everything?', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
                      content: const Text('Are you completely sure you want to delete all saved data? This action cannot be reversed.', style: TextStyle(color: Colors.white70)),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
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