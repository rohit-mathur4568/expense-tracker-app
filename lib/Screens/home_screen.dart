import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Cloud Import
import 'package:firebase_auth/firebase_auth.dart'; // Authentication Import
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

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section with Dynamic User Name
                const Text(
                  'Welcome Back,',
                  style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
                ),
                Text(
                  '$firstName!',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 20),

                // Premium Balance Card
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
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 10),

                // Live Transaction List
                expenses.isEmpty
                    ? const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Text("No transactions found. Add some!", style: TextStyle(color: AppColors.textSecondary)),
                    )
                )
                    : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: expenses.length,
                    itemBuilder: (context, index) {

                      // Extracting data and unique document ID
                      final doc = expenses[index];
                      final docId = doc.id;
                      final data =  doc.data() as Map<String, dynamic>;

                      final title = data['title'] ?? 'Unknown';
                      final category = data['category'] ?? 'Expense';
                      final amount = (data['amount'] ?? 0).toDouble();
                      final isExpense = category == 'Expense';

                      // Swipe to delete implementation
                      return Dismissible(
                        key: Key(docId),
                        direction: DismissDirection.endToStart,

                        // Swipe Background styling
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

                        // Deletion execution logic
                        onDismissed: (direction) async {
                          // 1. Delete data from Firebase Cloud
                          await FirebaseFirestore.instance.collection('expenses').doc(docId).delete();

                          // 2. Display success confirmation
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('$title deleted successfully!'),
                              backgroundColor: Colors.redAccent,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },

                        // Transaction card UI component
                        child: _buildTransactionCard(
                            title,
                            category,
                            '₹ ${amount.toStringAsFixed(2)}',
                            isExpense,
                            isExpense ? Icons.money_off : Icons.account_balance_wallet
                        ),
                      );
                    }
                )
              ],
            ),
          );
        },
      ),
    );
  }

  // Helper widget to construct individual transaction cards
  Widget _buildTransactionCard(String title, String category, String amount, bool isExpense, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
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
              color: AppColors.backgroundColor,
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
                Text(category, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
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