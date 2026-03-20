import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'firebase_options.dart';
import 'models/expense.dart';
import 'utils/app_colors.dart';

import 'Screens/main_screen.dart';
import 'Screens/login_screen.dart';
import 'utils/notification_helper.dart';

// GLOBAL THEME NOTIFIER: Controls the app theme from anywhere in the app
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() async {
  // Getting the Flutter engine ready before the app starts
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase for backend and authentication
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // FIREBASE OFFLINE PERSISTENCE (To run the app without internet)
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true, // Grants permission to save data offline
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED, // Unlimited cache space on the device
  );

  // Initialize Hive local database for offline storage
  await Hive.initFlutter();

  // Register the custom Expense model to the Hive database
  Hive.registerAdapter(ExpenseAdapter());

  // Open a box named 'expenses_box' to store all data locally
  await Hive.openBox<Expense>('expenses_box');

  // Open Settings Box & Load Saved Theme
  await Hive.openBox('settings_box');
  bool isDark = Hive.box('settings_box').get('isDarkMode', defaultValue: false);
  themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;

  // IMPORTANT: Initialize Notification Service and Schedule Reminder
  await NotificationHelper.init();
  await NotificationHelper.requestPermission();
// IMPORTANT: Initialize Notification Service
  await NotificationHelper.init();
  await NotificationHelper.requestPermission();

  // Check user preference from Hive before scheduling
  bool isReminderOn = Hive.box('settings_box').get('isReminderOn', defaultValue: true);
  if (isReminderOn) {
    await NotificationHelper.scheduleDailyReminder();
  }
  runApp(const ExpenseTrackerApp());
}

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ValueListenableBuilder listens to themeNotifier and rebuilds when it changes
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Expense Tracker',

          // Connect the mode to our global notifier
          themeMode: currentMode,

          // Define Light Theme properties
          theme: ThemeData.light().copyWith(
            colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryColor),
            scaffoldBackgroundColor: const Color(0xFFF8F9FA),
            cardColor: Colors.white,
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFFF8F9FA),
              foregroundColor: Colors.black,
              elevation: 0,
            ),
            useMaterial3: true,
          ),

          // Define Dark Theme properties
          darkTheme: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primaryColor,
              brightness: Brightness.dark,
            ),
            scaffoldBackgroundColor: const Color(0xFF121212),
            cardColor: const Color(0xFF1E1E1E),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF121212),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            bottomAppBarTheme: const BottomAppBarThemeData(color: Color(0xFF1E1E1E)),
            useMaterial3: true,
          ),

          // The Magic Router: Decides which screen to show based on login status
          home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return const MainScreen();
              }
              return const LoginScreen();
            },
          ),
        );
      },
    );
  }
}