import 'package:flutter/material.dart';
import 'package:hive/hive.dart'; // Database
import '../models/expense.dart';
import '../utils/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddExpense extends StatefulWidget {
  // Optional parameters added for Editing
  final String? docId;
  final String? currentTitle;
  final double? currentAmount;
  final String? currentCategory;

  const AddExpense({
    super.key,
    this.docId,
    this.currentTitle,
    this.currentAmount,
    this.currentCategory
  });

  @override
  State<AddExpense> createState() => _AddExpenseState();
}

class _AddExpenseState extends State<AddExpense> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  String _transactionType = 'Expense';

  @override
  void initState() {
    super.initState();
    // Pre-fill the text fields if we are editing an existing transaction
    if (widget.docId != null) {
      _titleController.text = widget.currentTitle ?? '';
      _amountController.text = widget.currentAmount?.toString() ?? '';
      _transactionType = widget.currentCategory ?? 'Expense';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Variable to easily check if we are in Edit Mode or Add Mode
    final isEditing = widget.docId != null;

    return Container(
      padding: EdgeInsets.only(
        top: 20, left: 20, right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              isEditing ? 'Edit Transaction' : 'Add Transaction',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                  color: _transactionType == 'Expense' ? AppColors.expenseColor : Colors.grey,
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
                  color: _transactionType == 'Income' ? AppColors.incomeColor : Colors.grey,
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
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            decoration: InputDecoration(
              labelText: 'Title',
              labelStyle: const TextStyle(color: Colors.grey),
              hintText: 'e.g., Zomato, Salary',
              hintStyle: const TextStyle(color: Colors.grey),
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
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            decoration: InputDecoration(
              labelText: 'Amount (INR)',
              labelStyle: const TextStyle(color: Colors.grey),
              hintText: '0.00',
              hintStyle: const TextStyle(color: Colors.grey),
              prefixIcon: const Icon(Icons.currency_rupee, color: AppColors.primaryColor),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 25),

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
                    const SnackBar(content: Text('Please enter a valid title and amount.')),
                  );
                  return;
                }

                // Save or Update in database
                try {
                  final user = FirebaseAuth.instance.currentUser;
                  final now = DateTime.now();

                  // Extracting clean date and time formats
                  final formattedDate = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
                  final formattedTime = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

                  if (isEditing) {
                    // Update existing document
                    await FirebaseFirestore.instance.collection('expenses').doc(widget.docId).update({
                      'title': enteredTitle,
                      'amount': enteredAmount,
                      'category': _transactionType,
                      // We intentionally do not update the date/time here to preserve the original log time
                    });
                  } else {
                    // Add new document with explicit date and time fields
                    await FirebaseFirestore.instance.collection('expenses').add({
                      'title' : enteredTitle,
                      'amount' : enteredAmount,
                      'category' : _transactionType,
                      'userId' : user?.uid,
                      'date' : now.toIso8601String(), // Maintained for backward compatibility
                      'displayDate' : formattedDate, // New explicit date field
                      'displayTime' : formattedTime, // New explicit time field
                      'timestamp' : FieldValue.serverTimestamp(), // Exact server time for precise sorting
                    });
                  }

                  if (context.mounted) Navigator.pop(context);
                } catch (error) {
                  debugPrint("Error saving to Firebase: $error");
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _transactionType == 'Expense' ? AppColors.expenseColor : AppColors.incomeColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: Text(
                isEditing ? 'Update Transaction' : 'Save',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}