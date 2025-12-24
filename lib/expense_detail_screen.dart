import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'classification.dart';
import 'classification_controller.dart';
import 'expense.dart';
import 'expense_controller.dart';

class ExpenseDetailScreen extends StatefulWidget {
  final Expense? expense;
  const ExpenseDetailScreen({super.key, this.expense});

  @override
  State<ExpenseDetailScreen> createState() => _ExpenseDetailScreenState();
}

class _ExpenseDetailScreenState extends State<ExpenseDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _notesController;

  DateTime _selectedDate = DateTime.now();
  Classification? _selectedCategory;
  Classification? _selectedSubcategory;
  Classification? _selectedPayee;
  Classification? _selectedPaymentMethod;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _notesController = TextEditingController();

    if (widget.expense != null) {
      final expense = widget.expense!;
      _selectedDate = expense.date;
      _amountController.text = (expense.amount / 100.0).toString();
      _notesController.text = expense.notes;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final classificationController = Get.find<ClassificationController>();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(widget.expense == null ? 'New Expense' : 'Edit Expense'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: widget.expense != null ? _deleteExpense : null,
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.only(
              left: 16,
              top: 16,
              right: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            //padding: const EdgeInsets.all(16),
            children: [
              // Date Picker Row
              Card(
                child: ListTile(
                  title: const Text('Date'),
                  subtitle: Text(
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: _showDatePicker,
                ),
              ),
              const SizedBox(height: 16),

              // Amount Field
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Amount (€)',
                  prefixText: '€ ',
                  prefixIcon: Icon(Icons.local_offer),
                ),
                validator: _amountValidator,
                onChanged: (value) {
                  // Auto-format as user types
                  final cleanValue = value.replaceAll(',', '.');
                  if (cleanValue != value) {
                    _amountController.value = TextEditingValue(
                      text: cleanValue,
                      selection: TextSelection.collapsed(offset: cleanValue.length),
                    );
                  }
                },
              ),
              const SizedBox(height: 16),

              // Category Dropdown
              _buildCategoryDropdown(classificationController),
              const SizedBox(height: 16),

              // Subcategory Dropdown (optional)
              _buildSubcategoryDropdown(classificationController),
              const SizedBox(height: 16),

              // Payee Dropdown
              _buildPayeeDropdown(classificationController),
              const SizedBox(height: 16),

              // Payment Method Dropdown
              _buildPaymentMethodDropdown(classificationController),
              const SizedBox(height: 16),

              // Notes Field
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  prefixIcon: Icon(Icons.notes),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 32),

              // Save/Update Button
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: Text(widget.expense == null ? 'Add Expense' : 'Update Expense'),
                onPressed: () => _saveExpense(Get.find<ExpenseController>()),  // ← FIXED!
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown(ClassificationController controller) {
    return DropdownButtonFormField<Classification>(
      initialValue: _selectedCategory,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Category *',
        prefixIcon: Icon(Icons.category),
      ),
      items: controller.classifications
          .where((c) => c.kind == 'expense_category' && c.parentId == null)  // Top-level only
          .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
          .toList(),
      validator: (value) => value == null ? 'Select category' : null,
      onChanged: (value) => setState(() {
        _selectedCategory = value;
        _selectedSubcategory = null;  // Reset subcategory when category changes
      }),
    );
  }

  Widget _buildSubcategoryDropdown(ClassificationController controller) {
    return DropdownButtonFormField<Classification>(
      initialValue: _selectedSubcategory,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: 'Subcategory',
        prefixIcon: const Icon(Icons.category_outlined),
        hintText: _selectedCategory == null ? 'Select category first' : 'Optional',
        enabled: _selectedCategory != null,  // disabled until category selected
      ),
      items: _selectedCategory == null
          ? []  // Empty when no category
          : controller.classifications
          .where((c) => c.kind == 'expense_category' &&
          c.parentId == _selectedCategory!.id)
          .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
          .toList(),
      onChanged: _selectedCategory == null
          ? null
          : (value) => setState(() => _selectedSubcategory = value),
    );
  }

  Widget _buildPayeeDropdown(ClassificationController controller) {
    return DropdownButtonFormField<Classification>(
      initialValue: _selectedPayee,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Payee',
        prefixIcon: Icon(Icons.store),
      ),
      items: controller.classifications
          .where((c) => c.kind == 'payee')
          .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
          .toList(),
      onChanged: (value) => setState(() => _selectedPayee = value),
    );
  }

  Widget _buildPaymentMethodDropdown(ClassificationController controller) {
    return DropdownButtonFormField<Classification>(
      initialValue: _selectedPaymentMethod,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Payment Method',
        prefixIcon: Icon(Icons.payment),
      ),
      items: controller.classifications
          .where((c) => c.kind == 'payment_method')
          .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
          .toList(),
      onChanged: (value) => setState(() => _selectedPaymentMethod = value),
    );
  }

  String? _amountValidator(String? value) {
    if (value == null || value.isEmpty) return 'Enter amount';
    final amount = double.tryParse(value.replaceAll(',', '.'));
    if (amount == null || amount <= 0) return 'Enter valid amount';
    return null;
  }

  void _showDatePicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _saveExpense(ExpenseController controller) async {
    if (!_formKey.currentState!.validate()) return;

    final amountText = _amountController.text.replaceAll(',', '.');
    final amount = double.parse(amountText);
    final amountCents = (amount * 100).round();

    final expense = Expense(
      id: widget.expense?.id,
      date: _selectedDate,
      categoryId: _selectedCategory!.id!,
      subcategoryId: _selectedSubcategory?.id,
      amount: amountCents,
      payeeId: _selectedPayee?.id,
      paymentMethodId: (_selectedPaymentMethod?.id)!,
      notes: _notesController.text.trim().isEmpty ? "" : _notesController.text.trim(),
    );

    if (widget.expense == null) {
      // New expense
      await controller.addExpense(expense);
      Get.back();
    } else {
      // Update existing
      final success = await controller.updateExpense(expense);
      if (success) {
        Get.back();
      } else {
        Get.snackbar('Error', 'Failed to update expense');
      }
    }
  }

  Future<void> _deleteExpense() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Expense?'),
        content: Text('Delete "${widget.expense!.date}" expense?'),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Get.back(result: true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final controller = Get.find<ExpenseController>();
      final result = await controller.deleteExpense(widget.expense!.id!);
      if (result) {
        Get.back(); // Close detail
        Get.back(); // Close list? Optional
      }
    }
  }
}
