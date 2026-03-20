import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import '../utils/app_colors.dart';
import '../utils/pdf_helper.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Analytics Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
          elevation: 0,
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.picture_as_pdf, color: AppColors.primaryColor),
              onPressed: () async {
                final snapshot = await FirebaseFirestore.instance
                    .collection('expenses')
                    .where('userId', isEqualTo: currentUser?.uid)
                    .get();

                final expensesList = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

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

                await PdfReportGenerator.generateAndPrintReport(expensesList, calculatedIncome, calculatedExpense);
              },
            ),
          ],
          bottom: const TabBar(
            indicatorColor: AppColors.primaryColor,
            labelColor: AppColors.primaryColor,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(icon: Icon(Icons.pie_chart), text: 'Overview'),
              Tab(icon: Icon(Icons.analytics), text: 'Detailed Insights'),
            ],
          ),
        ),

        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('expenses')
              .where('userId', isEqualTo: currentUser?.uid)
              .snapshots(),
          builder: (context, snapshot) {

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(child: Text('Failed to load analytics data.'));
            }

            final expenses = snapshot.data?.docs ?? [];

            if (expenses.isEmpty) {
              return const Center(
                child: Text('No transaction history available.', style: TextStyle(color: Colors.grey)),
              );
            }

            double totalIncome = 0;
            double totalExpense = 0;

            for (var doc in expenses) {
              final data = doc.data() as Map<String, dynamic>;
              final amount = (data['amount'] ?? 0).toDouble();

              if (data['category'] == 'Income') {
                totalIncome += amount;
              } else {
                totalExpense += amount;
              }
            }

            return TabBarView(
              children: [
                _buildOverviewTab(context, totalIncome, totalExpense),
                // Passing the raw expenses list to the Insights tab for the bottom sheet
                _buildInsightsTab(context, totalIncome, totalExpense, expenses),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildOverviewTab(BuildContext context, double income, double expense) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 300,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        _touchedIndex = -1;
                        return;
                      }
                      _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                borderData: FlBorderData(show: false),
                sectionsSpace: 2,
                centerSpaceRadius: 50,
                sections: _generateInteractiveSections(income, expense),
              ),
            ),
          ),
          const SizedBox(height: 40),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLegendCard(context, 'Total Income', income, Colors.green),
              _buildLegendCard(context, 'Total Expense', expense, Colors.redAccent),
            ],
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _generateInteractiveSections(double income, double expense) {
    final isIncomeTouched = _touchedIndex == 0;
    final isExpenseTouched = _touchedIndex == 1;

    final safeIncome = income > 0 ? income : 0.1;
    final safeExpense = expense > 0 ? expense : 0.1;

    return [
      PieChartSectionData(
        color: Colors.green,
        value: safeIncome,
        title: '${((safeIncome / (safeIncome + safeExpense)) * 100).toStringAsFixed(1)}%',
        radius: isIncomeTouched ? 75.0 : 60.0,
        titleStyle: TextStyle(
          fontSize: isIncomeTouched ? 18.0 : 14.0,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: const [Shadow(color: Colors.black45, blurRadius: 2)],
        ),
      ),
      PieChartSectionData(
        color: Colors.redAccent,
        value: safeExpense,
        title: '${((safeExpense / (safeIncome + safeExpense)) * 100).toStringAsFixed(1)}%',
        radius: isExpenseTouched ? 75.0 : 60.0,
        titleStyle: TextStyle(
          fontSize: isExpenseTouched ? 18.0 : 14.0,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: const [Shadow(color: Colors.black45, blurRadius: 2)],
        ),
      ),
    ];
  }

  Widget _buildLegendCard(BuildContext context, String title, double amount, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
        border: Border(bottom: BorderSide(color: color, width: 4)),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 5),
          Text(
            '₹${amount.toStringAsFixed(0)}',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  // Updated to accept the full list of expenses
  Widget _buildInsightsTab(BuildContext context, double income, double expense, List<QueryDocumentSnapshot> allExpenses) {
    final double netSavings = income - expense;
    final double savingsPercentage = income > 0 ? (netSavings / income) * 100 : 0;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Financial Health Summary', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _buildInsightTile(
            context,
            Icons.account_balance,
            'Net Savings',
            '₹${netSavings.toStringAsFixed(2)}',
            netSavings >= 0 ? Colors.green : Colors.red,
            onTap: () {
              // Filters only Income transactions when clicking Net Savings
              final savingsList = allExpenses.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return data['category'] == 'Income';
              }).toList();
              _showTransactionBottomSheet(context, 'Income History', savingsList);
            },
          ),
          const SizedBox(height: 15),
          _buildInsightTile(
            context,
            Icons.percent,
            'Savings Ratio',
            '${savingsPercentage.toStringAsFixed(1)}% of Income',
            Colors.blueAccent,
          ),
          const SizedBox(height: 15),
          _buildInsightTile(
            context,
            Icons.receipt_long,
            'Total Transactions',
            allExpenses.length.toString(),
            Colors.purpleAccent,
            onTap: () {
              // Shows all transactions
              _showTransactionBottomSheet(context, 'All Transactions', allExpenses);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInsightTile(BuildContext context, IconData icon, String title, String value, Color iconColor, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            if (onTap != null) ...[
              const SizedBox(width: 10),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ]
          ],
        ),
      ),
    );
  }

  // Reusable function to display the bottom sheet with a list of transactions
  void _showTransactionBottomSheet(BuildContext context, String title, List<QueryDocumentSnapshot> dataList) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Divider(),
              const SizedBox(height: 10),
              Expanded(
                child: dataList.isEmpty
                    ? const Center(child: Text('No transactions found.', style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                  itemCount: dataList.length,
                  itemBuilder: (context, index) {
                    final data = dataList[index].data() as Map<String, dynamic>;
                    final amount = data['amount'] ?? 0;
                    final isIncome = data['category'] == 'Income';
                    final itemTitle = data['title'] ?? 'Transaction';

                    // Safely parse the date regardless of how it is stored in Firebase
                    String dateStr = 'Unknown Date';
                    if (data['date'] != null) {
                      if (data['date'] is Timestamp) {
                        dateStr = (data['date'] as Timestamp).toDate().toString().split(' ')[0];
                      } else {
                        dateStr = data['date'].toString().split(' ')[0];
                      }
                    }

                    return Card(
                      elevation: 0,
                      color: Theme.of(context).cardColor,
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isIncome ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                          child: Icon(
                            isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                            color: isIncome ? Colors.green : Colors.red,
                          ),
                        ),
                        title: Text(itemTitle, style: const TextStyle(fontWeight: FontWeight.w500)),
                        subtitle: Text(dateStr, style: const TextStyle(fontSize: 12)),
                        trailing: Text(
                          '₹$amount',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isIncome ? Colors.green : Colors.red,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}