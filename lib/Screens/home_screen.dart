import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart'; // Database listen karne ke liye
import '../models/expense.dart'; // Apna data model
import '../utils/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      // ValueListenableBuilder Hive database ko continuously dekhta rehta hai
      child: ValueListenableBuilder(
        valueListenable: Hive.box<Expense>('expenses_box').listenable(),
        builder: (context, box, child) {

          // 1. Saara data database se list mein nikalna
          List<Expense> expenses = box.values.toList().cast<Expense>();

          // 2. Data ko naye se purane date ke hisaab se sort karna
          expenses.sort((a, b) => b.date.compareTo(a.date));

          // 3. Balance Calculate Karna (Real-time Math)
          double totalIncome = 0;
          double totalExpense = 0;

          for (var exp in expenses) {
            if (exp.category == 'Income') {
              totalIncome += exp.amount;
            } else {
              totalExpense += exp.amount;
            }
          }

          double totalBalance = totalIncome - totalExpense;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                const Text(
                  'Welcome Back,',
                  style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
                ),
                const Text(
                  'Rohit Bhai! 👋',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 20),

                // Premium Balance Card (Ab ye Live hai)
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
                        '₹ ${totalBalance.toStringAsFixed(2)}', // Live Balance
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
                      child: Text("No transactions yet. Add some!", style: TextStyle(color: AppColors.textSecondary)),
                    )
                )
                    : ListView.builder(
                  shrinkWrap: true, // Scroll view ke andar list view chalane ke liye
                  physics: const NeverScrollableScrollPhysics(), // Scroll parent karega
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    final expense = expenses[index];
                    final isExpense = expense.category == 'Expense';

                    return _buildTransactionCard(
                        expense.title,
                        expense.category,
                        '₹ ${expense.amount.toStringAsFixed(2)}',
                        isExpense,
                        isExpense ? Icons.money_off : Icons.account_balance_wallet
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Transaction Card Widget (Thoda clean kar diya)
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