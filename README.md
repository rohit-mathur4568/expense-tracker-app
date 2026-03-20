#  Premium Expense Tracker App

A robust, secure, and production-ready Expense Tracker mobile application built with Flutter and Firebase. This app helps users manage their daily finances with real-time cloud syncing and seamless offline support.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![Hive](https://img.shields.io/badge/Hive_Database-DB7093?style=for-the-badge&logo=databricks&logoColor=white)

## Key Features

* **🔒 Secure Authentication:** Multi-tenant architecture using Firebase Auth. Users can only access and modify their own financial data.
* **☁️ Cloud & Offline Sync:** Powered by Firestore with **Offline Persistence**. Add or edit expenses without the internet, and the app will automatically sync to the cloud once you're back online.
* **🌗 Smart Dark/Light Mode:** Seamlessly switch between themes. Your preference is saved locally using **Hive Database** so it remembers your choice on the next startup.
* **⚡ Dynamic UI/UX:** Features a beautiful, responsive dashboard with real-time balance calculations, swipe-to-delete functionality, and an intuitive inline editing bottom sheet.
* **📱 Production Ready:** Fully optimized with a custom Android launcher icon and clean architecture.

## 🛠️ Tech Stack

* **Frontend:** Flutter (Dart)
* **Backend:** Firebase (Authentication & Cloud Firestore)
* **Local Storage:** Hive (for theme preferences)
* **State Management:** ValueNotifier (for global theme toggling)


## 🚀 Getting Started & Setup

If you want to run this project locally, follow these steps:

### 1. Prerequisites
* Flutter SDK installed on your machine.
* A Firebase Project configured with Authentication (Email/Password) and Cloud Firestore enabled.

### 2. Firebase Database Configuration (Crucial)
Because this app uses complex queries (filtering by `userId` and ordering by `date` simultaneously), **Firebase requires a Composite Index**.

1. Run the app and log in.
2. Check your IDE's Debug Console for a Firestore error link.
3. `Ctrl + Click` the link to open the Firebase Console.
4. Click **Create Index** and wait 2-3 minutes for the status to show as "Enabled".
5. Restart the app.

### 3. Run the App
```bash
flutter pub get
flutter run
👨‍💻 Author
Rohit Mathur

GitHub:https://github.com/rohit-mathur4568

LinkedIn: https://www.linkedin.com/in/rohit-mathur-91b41a2b3/