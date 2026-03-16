import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import '../utils/app_colors.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  // State variable to track user interaction with the pie chart
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    // Implementing DefaultTabController to provide a multi-view analytics dashboard
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          title: const Text('Analytics Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: AppColors.backgroundColor,
          elevation: 0,
          centerTitle: true,
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
          stream: FirebaseFirestore.instance.collection('expenses').snapshots(),
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
            int totalTransactions = expenses.length;

            // Data aggregation logic
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
                // Tab 1: Interactive Overview View
                _buildOverviewTab(totalIncome, totalExpense),

                // Tab 2: Detailed Insights View
                _buildInsightsTab(totalIncome, totalExpense, totalTransactions),
              ],
            );
          },
        ),
      ),
    );
  }

  // Constructs the primary interactive pie chart layout
  Widget _buildOverviewTab(double income, double expense) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Interactive Pie Chart Container
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

          // Custom Legend UI
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLegendCard('Total Income', income, Colors.green),
              _buildLegendCard('Total Expense', expense, Colors.redAccent),
            ],
          ),
        ],
      ),
    );
  }

  // Generates sections with dynamic radius based on user touch interaction
  List<PieChartSectionData> _generateInteractiveSections(double income, double expense) {
    final isIncomeTouched = _touchedIndex == 0;
    final isExpenseTouched = _touchedIndex == 1;

    // Prevent rendering errors if exact zero by providing minimal baseline
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

  // Constructs individual legend indicator cards
  Widget _buildLegendCard(String title, double amount, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
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

  // Constructs the secondary insights layout displaying aggregated metrics
  Widget _buildInsightsTab(double income, double expense, int totalTransactions) {
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
            Icons.account_balance,
            'Net Savings',
            '₹${netSavings.toStringAsFixed(2)}',
            netSavings >= 0 ? Colors.green : Colors.red,
          ),
          const SizedBox(height: 15),
          _buildInsightTile(
            Icons.percent,
            'Savings Ratio',
            '${savingsPercentage.toStringAsFixed(1)}% of Income',
            Colors.blueAccent,
          ),
          const SizedBox(height: 15),
          _buildInsightTile(
            Icons.receipt_long,
            'Total Transactions',
            totalTransactions.toString(),
            Colors.purpleAccent,
          ),
        ],
      ),
    );
  }

  // Helper widget to construct insight data rows
  Widget _buildInsightTile(IconData icon, String title, String value, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
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
        ],
      ),
    );
  }
}