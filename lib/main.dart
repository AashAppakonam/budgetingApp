import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/budget_provider.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => BudgetProvider(),
      child: const BudgetApp(),
    ),
  );
}

class BudgetApp extends StatelessWidget {
  const BudgetApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<BudgetProvider>().isDarkMode;

    return MaterialApp(
      title: 'Minimal Budget',
      theme: isDark
          ? ThemeData(
              brightness: Brightness.dark,
              scaffoldBackgroundColor: Colors.black,
              primaryColor: const Color(0xFF00E676),
              colorScheme: const ColorScheme.dark(
                primary: Color(0xFF00E676),
                secondary: Colors.white,
                surface: Color(0xFF151515),
              ),
              useMaterial3: true,
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
                titleTextStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.5,
                  color: Colors.white,
                ),
                iconTheme: IconThemeData(color: Colors.white),
              ),
            )
          : ThemeData(
              brightness: Brightness.light,
              scaffoldBackgroundColor: const Color(0xFFF5F5F5),
              primaryColor: const Color(0xFF00E676),
              colorScheme: const ColorScheme.light(
                primary: Color(0xFF00E676),
                secondary: Colors.black,
                surface: Colors.white,
              ),
              useMaterial3: true,
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
                titleTextStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.5,
                  color: Colors.black,
                ),
                iconTheme: IconThemeData(color: Colors.black),
              ),
            ),
      home: const MainScreen(),
    );
  }
}
