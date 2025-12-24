import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'expense.dart';
import 'expense_controller.dart';
import 'expense_detail_screen.dart';
import 'utils.dart';

class ExpenseListScreen extends GetView<ExpenseController> {
  const ExpenseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
        actions: [
          Obx(() => PopupMenuButton<String>(
            enabled: !controller.isLoading.value,
            onSelected: _handleAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'add',
                child: Row(children: [
                  Icon(Icons.add),
                  SizedBox(width: 8),
                  Text('Add Expense'),
                ]),
              ),
              const PopupMenuItem(
                value: 'refresh',
                child: Row(children: [
                  Icon(Icons.refresh),
                  SizedBox(width: 8),
                  Text('Refresh'),
                ]),
              ),
            ],
          )),
        ],
      ),
      body: Obx(() => _buildBody()),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.isLoading.value ? null : _addNewExpense,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (controller.isLoading.value) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.expenses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.receipt_long, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No expenses yet', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _addNewExpense,
              child: const Text('Add your first expense'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: controller.expenses.length,
      itemBuilder: (context, index) {
        final expense = controller.expenses[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              child: Text(formatAmount(expense.amount)),
            ),
            title: Text('${expense.date}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('€${formatAmount(expense.amount)}'),
                if (expense.notes.isNotEmpty) Text(expense.notes),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) => _handleItemAction(expense.id!, value),
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
            onTap: () => _editExpense(expense),
          ),
        );
      },
    );
  }

  // Action handlers
  Future<void> _handleAction(String value) async {
    switch (value) {
      case 'add':
        _addNewExpense();
        break;
      case 'refresh':
        await controller.loadExpenses();
        break;
    }
  }

  Future<void> _handleItemAction(int expenseId, String value) async {
    switch (value) {
      case 'edit':
        final expense = controller.expenses.firstWhere((e) => e.id == expenseId);
        _editExpense(expense);
        break;
      case 'delete':
        final confirmed = await _confirmDelete(expenseId);
        if (confirmed) {
          final result = await controller.deleteExpense(expenseId);
          _showResult(result ? "Deleted" : "Something wrong!");
        }
        break;
    }
  }

  void _addNewExpense() {
    Get.to(() => const ExpenseDetailScreen());
  }

  void _editExpense(Expense expense) {
    Get.to(() => ExpenseDetailScreen(expense: expense));
  }

  Future<bool> _confirmDelete(int expenseId) async {
    return await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Expense?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Get.back(result: true),
            child: const Text('Delete'),
          ),
        ],
      ),
    ) ?? false;
  }

  void _showResult(String result) {
    if (result.contains('Deleted')) {
      Get.snackbar('Success', result, snackPosition: SnackPosition.TOP);
    } else {
      Get.snackbar('Error', result, snackPosition: SnackPosition.TOP);
    }
  }
}
