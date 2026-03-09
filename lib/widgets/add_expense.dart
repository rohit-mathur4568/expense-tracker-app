import 'package:flutter/material.dart';
import 'package:hive/hive.dart'; // Database
import '../models/expense.dart'; // Tera banaya hua model
import '../utils/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddExpense extends StatefulWidget {
  const AddExpense({super.key});

  @override
  State<AddExpense> createState() => _AddExpenseState();
}

class _AddExpenseState extends State<AddExpense> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  String _transactionType = 'Expense';

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 20, left: 20, right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              'Add Transaction',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
          ),
          const SizedBox(height: 20),

          // Income and Expense Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ChoiceChip(
                label: const Text('Expense', style: TextStyle(fontWeight: FontWeight.bold)),
                selected: _transactionType == 'Expense',
                selectedColor: AppColors.expenseColor.withOpacity(0.2),
                labelStyle: TextStyle(
                  color: _transactionType == 'Expense' ? AppColors.expenseColor : AppColors.textSecondary,
                ),
                onSelected: (bool selected) {
                  setState(() { _transactionType = 'Expense'; });
                },
              ),
              const SizedBox(width: 20),
              ChoiceChip(
                label: const Text('Income', style: TextStyle(fontWeight: FontWeight.bold)),
                selected: _transactionType == 'Income',
                selectedColor: AppColors.incomeColor.withOpacity(0.2),
                labelStyle: TextStyle(
                  color: _transactionType == 'Income' ? AppColors.incomeColor : AppColors.textSecondary,
                ),
                onSelected: (bool selected) {
                  setState(() { _transactionType = 'Income'; });
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Title',
              hintText: 'e.g., Zomato, Salary',
              prefixIcon: const Icon(Icons.title, color: AppColors.primaryColor),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 15),

          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Amount (₹)',
              hintText: '0.00',
              prefixIcon: const Icon(Icons.currency_rupee, color: AppColors.primaryColor),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 25),

          // ASLI JADU YAHAN HAI (Save Button)
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () async {
                final enteredTitle = _titleController.text;
                final enteredAmount = double.tryParse(_amountController.text) ?? 0.0;

                // Validation
                if (enteredTitle.isEmpty || enteredAmount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Enter correct title and amount!')),
                  );
                  return;
                }

                // Database mein save karna
                try {
                  await FirebaseFirestore.instance.collection('expenses').add({
                    'title' : enteredTitle,
                    'amount' : enteredAmount,
                    'date' : DateTime.now().toIso8601String(), //convert date into a text
                    'category' : _transactionType,
                  });
                  print("data goes to firebase ! 👍");

                  Navigator.pop(context);
                } catch (error) {
                  print("Error in Cloud : $error");
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _transactionType == 'Expense' ? AppColors.expenseColor : AppColors.incomeColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text(
                'Save',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}