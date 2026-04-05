import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/budget_provider.dart';
import '../widgets/budget_ring_painter.dart';
import 'add_entry_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  void _showBudgetDialog(BuildContext context) {
    final provider = Provider.of<BudgetProvider>(context, listen: false);
    final controller = TextEditingController(text: provider.totalBudget.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF151515),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Set Monthly Budget', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          decoration: const InputDecoration(
            prefixText: '\$ ',
            prefixStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white54),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF00E676))),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
             style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00E676),
              foregroundColor: Colors.black,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              if (controller.text.isNotEmpty) {
                provider.setBudget(double.parse(controller.text));
              }
              Navigator.pop(context);
            },
            child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showSortFilterDialog(BuildContext context) {
    final provider = Provider.of<BudgetProvider>(context, listen: false);
    SortOption tempSort = provider.currentSort;
    String? tempCategory = provider.filterCategoryId;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF151515),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 24.0, 
                left: 24.0, 
                right: 24.0, 
                bottom: MediaQuery.of(context).viewInsets.bottom + 24.0
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Sort & Filter', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      if (tempSort != SortOption.dateDesc || tempCategory != null)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              tempSort = SortOption.dateDesc;
                              tempCategory = null;
                            });
                          },
                          style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(50, 30), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                          child: const Text('Clear All', style: TextStyle(color: Colors.redAccent, fontSize: 14)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  const Text('Sort By', style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<SortOption>(
                    value: tempSort,
                    icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white54),
                    dropdownColor: const Color(0xFF1E1E1E),
                    decoration: const InputDecoration(
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF00E676))),
                    ),
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    items: const [
                      DropdownMenuItem(value: SortOption.dateDesc, child: Text('Date: Newest First')),
                      DropdownMenuItem(value: SortOption.dateAsc, child: Text('Date: Oldest First')),
                      DropdownMenuItem(value: SortOption.amountDesc, child: Text('Amount: Highest First')),
                      DropdownMenuItem(value: SortOption.amountAsc, child: Text('Amount: Lowest First')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => tempSort = val);
                    },
                  ),
                  const SizedBox(height: 30),
                  const Text('Filter by Category', style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String?>(
                    value: tempCategory,
                    icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white54),
                    dropdownColor: const Color(0xFF1E1E1E),
                    decoration: const InputDecoration(
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF00E676))),
                    ),
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('All Categories')),
                      ...provider.categories.map((c) => DropdownMenuItem(value: c.id, child: Text('${c.emoji}  ${c.name}'))),
                    ],
                    onChanged: (val) {
                      setState(() => tempCategory = val);
                    },
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00E676),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      provider.setSortAndFilter(tempSort, tempCategory);
                      Navigator.pop(context);
                    },
                    child: const Text('APPLY', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: 1.0)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Overview'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen())),
            tooltip: 'Settings',
          ),
          IconButton(
            icon: const Icon(Icons.edit_calendar),
            onPressed: () => _showBudgetDialog(context),
            tooltip: 'Set Budget',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<BudgetProvider>(
        builder: (context, budgetState, child) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Base Budget', style: TextStyle(color: Colors.white54, fontSize: 14, fontWeight: FontWeight.normal)),
                    Text('\$${budgetState.totalBudget.toStringAsFixed(2)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // Pie Chart / Ring Graphic
              Center(
                child: SizedBox(
                  height: 220,
                  width: 220,
                  child: CustomPaint(
                    painter: BudgetRingPainter(
                      categorySpent: budgetState.categorySpent,
                      total: budgetState.totalBudget + budgetState.totalIncome,
                    ),
                    child: Center(
                      child: budgetState.totalBudget == 0
                          ? ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00E676),
                                foregroundColor: Colors.black,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              ),
                              onPressed: () => _showBudgetDialog(context),
                              child: const Text('Set Budget', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('Remaining', style: TextStyle(color: Colors.white54, fontSize: 14, letterSpacing: 1.0)),
                                const SizedBox(height: 4),
                                Text(
                                  '\$${budgetState.remainingBudget.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -1.5,
                                    color: budgetState.remainingBudget >= 0
                                        ? Colors.white
                                        : Colors.redAccent,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // Transaction Log Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('TRANSACTIONS', style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                    GestureDetector(
                      onTap: () => _showSortFilterDialog(context),
                      child: Row(
                        children: [
                          if (budgetState.hasActiveSortOrFilter)
                            const Padding(
                              padding: EdgeInsets.only(right: 6.0),
                              child: Text('Filtered', style: TextStyle(color: Color(0xFF00E676), fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                          Icon(
                            Icons.filter_list, 
                            color: budgetState.hasActiveSortOrFilter ? const Color(0xFF00E676) : Colors.white54,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Transaction Log
              Expanded(
                child: Container(
                  color: Colors.black,
                  child: budgetState.transactions.isEmpty
                      ? const Center(child: Text('No entries found.', style: TextStyle(color: Colors.white24)))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemCount: budgetState.transactions.length,
                          itemBuilder: (context, index) {
                            final tx = budgetState.transactions[index];
                            return Dismissible(
                              key: Key(tx.id),
                              background: Container(
                                color: Colors.redAccent,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                child: const Icon(Icons.delete, color: Colors.white),
                              ),
                              direction: DismissDirection.endToStart,
                              confirmDismiss: (direction) async {
                                return await showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    backgroundColor: const Color(0xFF151515),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    title: const Text('Delete Entry?', style: TextStyle(fontWeight: FontWeight.bold)),
                                    content: const Text('Are you sure you want to remove this transaction?', style: TextStyle(color: Colors.white70)),
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
                                        child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              onDismissed: (_) => budgetState.deleteTransaction(tx.id),
                              child: Container(
                                decoration: const BoxDecoration(
                                  border: Border(bottom: BorderSide(color: Colors.white10, width: 1)),
                                ),
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: Text(tx.category.emoji, style: const TextStyle(fontSize: 22)),
                                  title: Text(tx.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                                  subtitle: Text(
                                    '${tx.category.name}  •  ${DateFormat('EEEE, MMMM d, yyyy').format(tx.date)}',
                                    style: const TextStyle(color: Colors.white38, fontSize: 13),
                                  ),
                                  trailing: Text(
                                    tx.isIncome ? '+\$${tx.amount.toStringAsFixed(2)}' : '-\$${tx.amount.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700, 
                                      fontSize: 16,
                                      letterSpacing: -0.5,
                                      color: tx.isIncome ? const Color(0xFF00E676) : Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
              Container(
                color: Colors.black,
                padding: const EdgeInsets.only(top: 15, left: 24, right: 24),
                child: SafeArea(
                  top: false,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('TOTAL SPENT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white38, letterSpacing: 1.0)),
                          Text('\$${budgetState.totalSpent.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: -0.5)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00E676),
                            foregroundColor: Colors.black,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AddEntryScreen()),
                          ),
                          child: const Text('ADD ENTRY', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: 1.0)),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
