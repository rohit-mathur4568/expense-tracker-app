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