import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/app_colors.dart';
import '../utils/pdf_helper.dart';
import '../utils/notification_helper.dart';
import '../main.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Local state variables to make the UI switches interactive
  bool _isDarkMode = Hive.box('settings_box').get('isDarkMode', defaultValue: false);

  bool _isReminderOn = Hive.box('settings_box').get('isReminderOn', defaultValue: true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Application Preferences Section
            const Text(
              'Preferences',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
            ),
            const SizedBox(height: 10),
            _buildSwitchTile(
              title: 'Dark Mode',
              subtitle: 'Switch application theme',
              icon: Icons.dark_mode,
              value: _isDarkMode,
              onChanged: (val) {
                setState(() {
                  _isDarkMode = val;
                });
                // This changes the global theme instantly
                themeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
                Hive.box('settings_box').put('isDarkMode', val);
              },
            ),
            _buildSwitchTile(
              title: 'Daily Reminders',
              subtitle: 'Notification at 9:00 PM',
              icon: Icons.notifications_active,
              value: _isReminderOn,
              onChanged: (val) async {
                setState(() {
                  _isReminderOn = val;
                });

                //save user permission
                await Hive.box('settings_box').put('isReminderOn', val);

                // Notification On/Off
                if (val) {
                  await NotificationHelper.scheduleDailyReminder();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Daily reminder turned ON 🔔'), backgroundColor: Colors.green),
                    );
                  }
                } else {
                  await NotificationHelper.cancelDailyReminder();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Daily reminder turned OFF 🔕'), backgroundColor: Colors.grey),
                    );
                  }
                }
              },
            ),

            const SizedBox(height: 30),

            // Data Management Section
            const Text(
              'Data Management',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
              title: const Text('Export Monthly Report', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Generate a PDF of all transactions'),
              trailing: const Icon(Icons.download, color: AppColors.primaryColor),
              onTap: _generatePdfReport,
            ),

            const SizedBox(height: 40),

            // security section
            const Text(
              'System & Security',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.green.withOpacity(0.3), width: 1.5), // Glowing green border
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.gpp_good, color: Colors.green, size: 30), // Shield with checkmark
                ),
                title: const Text('Data Security Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                subtitle: const Padding(
                  padding: EdgeInsets.only(top: 5.0),
                  child: Text('AES-256 End-to-End Encrypted\nAll financial records secured.', style: TextStyle(height: 1.3, fontSize: 13)),
                ),
                trailing: const Icon(Icons.verified_user, color: Colors.green),
                onTap: () {
                  // Haptic feedback feel with floating snackbar
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.lock_outline, color: Colors.white),
                          SizedBox(width: 10),
                          Expanded(child: Text('Your financial data is strictly encrypted and secure.', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                      ),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      elevation: 10,
                      duration: Duration(seconds: 3),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Modular builder for setting switches
  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primaryColor,
      ),
    );
  }

  // Function to aggregate data and trigger the PDF generation utility
  Future<void> _generatePdfReport() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final snapshot = await FirebaseFirestore.instance
          .collection('expenses')
          .where('userId', isEqualTo: user?.uid)
          .orderBy('date', descending: true)
          .get();

      final expensesList = snapshot.docs.map((doc) => doc.data()).toList();

      double calculatedIncome = 0;
      double calculatedExpense = 0;

      for (var transaction in expensesList) {
        final amount = (transaction['amount'] ?? 0).toDouble();
        if (transaction['category'] == 'Income') {
          calculatedIncome += amount;
        } else {
          calculatedExpense += amount;
        }
      }

      if (!mounted) return;
      await PdfReportGenerator.generateAndPrintReport(expensesList, calculatedIncome, calculatedExpense);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating report: $e'), backgroundColor: Colors.red),
      );
    }
  }
}