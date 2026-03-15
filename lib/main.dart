import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Required for checking login state
import 'package:hive_flutter/hive_flutter.dart';

import 'firebase_options.dart';
import 'models/expense.dart';
import 'utils/app_colors.dart';

// Fixed the capital 'S' issue to match your folder structure perfectly
import 'Screens/main_screen.dart';
import 'Screens/login_screen.dart';

void main() async {
  // 1. Getting the Flutter engine ready before the app starts
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize Firebase for backend and authentication
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 3. Initialize Hive local database for offline storage
  await Hive.initFlutter();

  // 4. Register the custom Expense model to the Hive database
  Hive.registerAdapter(ExpenseAdapter());

  // 5. Open a 'box' (local table) named 'expenses_box' to store all data
  await Hive.openBox<Expense>('expenses_box');

  runApp(const ExpenseTrackerApp());
}

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Hides the red debug banner
      title: 'Expense Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryColor),
        useMaterial3: true,
      ),

      // 🚀 The Magic Router: Decides which screen to show based on login status
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // If the snapshot has data, it means the user is successfully logged in
          if (snapshot.hasData) {
            return const MainScreen(); // Take them directly to the app
          }
          // If no data is found, the user is logged out. Show the Login Screen.
          return const LoginScreen();
        },
      ),
    );
  }
}