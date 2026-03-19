import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Retrieve the active user session from Firebase
    final currentUser = FirebaseAuth.instance.currentUser;

    // Extract the first name from the full display name, or fallback to 'User'
    final firstName = currentUser?.displayName?.split(' ').first ?? 'User';

    return SafeArea(
      // StreamBuilder to fetch live data from the cloud
      child: StreamBuilder<QuerySnapshot>(
        // This stream fetches data sorted by date in descending order
        stream: FirebaseFirestore.instance
            .collection('expenses')
            .where('userId', isEqualTo: currentUser?.uid)
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {

          // 1. Handle loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryColor));
          }

          // 2. Handle error state
          if (snapshot.hasError) {
            return const Center(child: Text("Database connection error.", style: TextStyle(color: Colors.red)));
          }

          // 3. Extract data and initialize calculation variables
          final expenses = snapshot.data?.docs ?? [];
          double totalIncome = 0;
          double totalExpense = 0;

          // 4. Calculate live balance iteratively
          for (var doc in expenses) {
            final data = doc.data() as Map<String, dynamic>;
            final amount = (data['amount'] ?? 0).toDouble();

            if (data['category'] == 'Income') {
              totalIncome += amount;
            } else {
              totalExpense += amount;
            }
          }

          double totalBalance = totalIncome - totalExpense;

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section with Dynamic User Name
                const Text(
                  'Welcome Back,',
                  style: TextStyle(fontSize: 16, color: Colors.grey), // Generic grey works in both modes
                ),
                Text(
                  '$firstName!',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold), // Color removed for Auto-Dark mode
                ),
                const SizedBox(height: 20),

                // Premium Balance Card (This will stay fixed now)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryColor, Color(0xFF009688)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total Balance', style: TextStyle(color: Colors.white70, fontSize: 16)),
                      const SizedBox(height: 10),
                      Text(
                        '₹ ${totalBalance.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.arrow_downward, color: Colors.white, size: 20),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Income', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                  Text('₹ ${totalIncome.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(Icons.arrow_upward, color: Colors.white, size: 20),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Expense', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                  Text('₹ ${totalExpense.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Recent Transactions Heading
                const Text(
                  'Recent Transactions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // Auto-adapts to Dark/Light
                ),
                const SizedBox(height: 10),

                Expanded(
                  child: expenses.isEmpty
                      ? const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: Text("No transactions found. Add some!", style: TextStyle(color: Colors.grey)),
                      )
                  )
                      : ListView.builder(
                      itemCount: expenses.length,
                      itemBuilder: (context, index) {

                        final doc = expenses[index];
                        final docId = doc.id;
                        final data =  doc.data() as Map<String, dynamic>;

                        final title = data['title'] ?? 'Unknown';
                        final category = data['category'] ?? 'Expense';
                        final amount = (data['amount'] ?? 0).toDouble();
                        final isExpense = category == 'Expense';

                        return Dismissible(
                          key: Key(docId),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.red.shade400,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Icon(Icons.delete_sweep, color: Colors.white, size: 30),
                          ),
                          onDismissed: (direction) async {
                            await FirebaseFirestore.instance.collection('expenses').doc(docId).delete();
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('$title deleted successfully!'),
                                backgroundColor: Colors.redAccent,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          // Passed context here to get the correct theme colors
                          child: _buildTransactionCard(
                              context,
                              title,
                              category,
                              '₹ ${amount.toStringAsFixed(2)}',
                              isExpense,
                              isExpense ? Icons.money_off : Icons.account_balance_wallet
                          ),
                        );
                      }
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  // Helper widget updated with BuildContext to catch theme dynamically
  Widget _buildTransactionCard(BuildContext context, String title, String category, String amount, bool isExpense, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        // 🔥 CHANGE 3: Theme.of(context).cardColor lagaya taaki Dark Mode me card dikhe
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              // Background adapts dynamically now
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: isExpense ? AppColors.expenseColor : AppColors.primaryColor),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 5),
                Text(category, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Text(
            isExpense ? '- $amount' : '+ $amount',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isExpense ? AppColors.expenseColor : AppColors.incomeColor,
            ),
          ),
        ],
      ),
    );
  }
}