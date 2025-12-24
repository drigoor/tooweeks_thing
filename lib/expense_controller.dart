import 'package:get/get.dart';

import 'expense.dart';
import 'expense_repo.dart';

class ExpenseController extends GetxController {
  final ExpenseRepository repo = ExpenseRepository();

  final expenses = <Expense>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    isLoading.value = true;
    try {
      final data = await repo.getAll();
      expenses.assignAll(data);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addExpense(Expense expense) async {
    await repo.insert(expense);
    expenses.add(expense);
  }

  Future<bool> updateExpense(Expense updated) async {
    final count = await repo.update(updated, updated.id!);
    if (count == 0) {
      return false;
    }

    final index = expenses.indexWhere((e) => e.id == updated.id);
    if (index == -1) {
      return false;
    }
    expenses[index] = updated;

    return true;
  }

  Future<bool> deleteExpense(int id) async {
    final count = await repo.baseDelete(id);
    if (count == 0) {
      return false;
    }

    final initialCount = expenses.length;
    expenses.removeWhere((e) => e.id == id);
    final currentCount = expenses.length;
    if (currentCount != (initialCount - 1)) {
      return false;
    }

    return true;
  }
}
