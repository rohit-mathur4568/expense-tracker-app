# 🗄️ Database Setup Guide (Firebase Firestore)

This document explains how to connect and set up the Firebase Cloud Firestore database for the Expense Tracker app. Follow these steps if you are cloning this project or setting it up on a new machine.

## 📌 Prerequisites
1. A Google Account.
2. [Node.js](https://nodejs.org/) installed on your PC (Required for Firebase CLI).
3. Flutter SDK installed.

---

## Step 1: Create Firebase Project & Firestore Database
1. Go to the [Firebase Console](https://console.firebase.google.com/).
2. Click **Add Project** -> Name it (e.g., `expense-tracker-app`).
3. Turn off Google Analytics and click **Create Project**.
4. In the left sidebar, navigate to **Build > Firestore Database**.
5. Click **Create Database**.
6. **IMPORTANT:** Choose **Start in Test Mode** (this allows read/write access for development).
7. Select a server location close to you (e.g., `asia-south1` for India) and click **Enable**.

---

## Step 2: Install Firebase CLI Tools
Open your terminal (Command Prompt, PowerShell, or VS Code/Android Studio terminal) and install the Firebase tools globally:

```bash
# Install Firebase tools
npm install -g firebase-tools

# Login to your Google account (Opens browser)
firebase login
Step 3: Install FlutterFire CLI
This is the official tool to connect Flutter with Firebase easily.

Bash
dart pub global activate flutterfire_cli
Step 4: Configure Firebase in the App
Link your Flutter code to your Firebase project. Go to your Firebase project settings to find your Project ID.

Run this command in your project terminal:

Bash
# Replace YOUR_PROJECT_ID with your actual Firebase Project ID
dart pub global run flutterfire_cli:flutterfire configure --project=YOUR_PROJECT_ID
Hit Enter to select all platforms (Android, iOS, Web). This will automatically generate the lib/firebase_options.dart file containing all the API keys.

Step 5: Install Flutter Dependencies
Add the required Firebase packages to your pubspec.yaml file:

Bash
flutter pub add firebase_core cloud_firestore
flutter clean
flutter pub get
🔒 Security Note
The auto-generated file lib/firebase_options.dart contains sensitive API keys.
DO NOT push this file to GitHub.
It is already added to the .gitignore file. Anyone cloning this repo must generate their own firebase_options.dart file by following Step 4.

Gemini said
Here is the rest of the documentation for your db_setup.md file. It includes the initialization code, the exact database structure required for your project, and the security rules.

Just copy and paste this directly below your Step 5:

Step 6: Initialize Firebase in the Application
Before performing any database operations, Firebase must be initialized at the root of your Flutter application. Update your lib/main.dart file to include the initialization logic.

Dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Auto-generated in Step 4

void main() async {
  // Ensure the Flutter framework is bound to the engine before async operations
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase using the platform-specific configurations
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const ExpenseTrackerApp());
}
Step 7: Database Structure (Conceptual Model)
This application utilizes Firebase Firestore, a NoSQL document database. All financial transactions are stored within a primary collection.

Collection Name: expenses

Document Fields & Data Types:

id (String): A unique, auto-generated identifier for the transaction.

title (String): A brief description of the transaction (e.g., "Zomato Lunch", "Monthly Salary").

amount (Double/Number): The numerical value of the transaction.

category (String): The classification of the transaction (e.g., "Income" or "Expense").

date (Timestamp): The exact date and time the transaction was recorded, used for chronological sorting.

Step 8: Firestore Security Rules
If you selected "Test Mode" during Step 1, your database allows open read/write access for 30 days. To secure your database and ensure only authenticated users (logged in via Google) can access or modify the expense data, update your Firestore rules.

Go to the Firebase Console.

Navigate to Firestore Database > Rules tab.

Replace the existing rules with the following production-ready rules:

JavaScript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Target the 'expenses' collection
    match /expenses/{document=**} {
      // Allow read and write operations ONLY if the user is authenticated
      allow read, write: if request.auth != null;
    }
  }
}
Click Publish.

Step 9: Verifying the Connection
To verify that your app is successfully connected to Firestore:

Run the application on an emulator or physical device (flutter run).

Log in using the Google Sign-In button.

Add a new expense using the Add Transaction form.

Open the Firebase Console, go to Firestore Database, and verify that a new document has been created in the expenses collection.