import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/app_colors.dart';
import '../utils/pdf_helper.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Local state variables to make the UI switches interactive
  bool _isDarkMode = false;
  bool _isReminderOn = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.backgroundColor,
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
              subtitle: 'Experimental feature',
              icon: Icons.dark_mode,
              value: _isDarkMode,
              onChanged: (val) {
                setState(() {
                  _isDarkMode = val;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Dark mode requires an app restart to apply globally.')),
                );
              },
            ),
            _buildSwitchTile(
              title: 'Daily Reminders',
              subtitle: 'Notification at 9:00 PM',
              icon: Icons.notifications_active,
              value: _isReminderOn,
              onChanged: (val) {
                setState(() {
                  _isReminderOn = val;
                });
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

            // Developer Authentication Card
            const Text(
              'About Developer',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.cardColor,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                ],
                border: Border.all(color: AppColors.primaryColor.withOpacity(0.2)),
              ),
              child: const Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.primaryColor,
                    child: Icon(Icons.engineering, size: 40, color: Colors.white),
                  ),
                  SizedBox(height: 15),
                  Text(
                    'Rohit Mathur',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'B.Tech CSE - 3rd Year',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  SizedBox(height: 15),
                  Text(
                    'Expense Tracker Application v1.0\nDeveloped using Flutter & Firebase',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
                  ),
                ],
              ),
            ),
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
      final snapshot = await FirebaseFirestore.instance.collection('expenses').get();
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