import 'package:flutter/material.dart';
import 'screens/main_screen.dart';
import 'utils/app_colors.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/expense.dart';

void main() async {
// Getting the engine ready before the app starts
  WidgetsFlutterBinding.ensureInitialized();

  //stat hive database
  await Hive.initFlutter();

  // join our model to the database
  Hive.registerAdapter(ExpenseAdapter());

  // 'expenses_box' naam ka ek dibba (box) kholna jisme saara data save hoga
  await Hive.openBox<Expense>('expenses_box');

  runApp(const ExpenseTrackerApp());
}

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryColor),
        useMaterial3: true,
      ),
      home: const MainScreen(), // Yahan humne main screen link kar di
    );
  }
}