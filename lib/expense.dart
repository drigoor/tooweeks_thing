class Expense {
  final int? id;
  final DateTime date;
  final int categoryId;
  final int? subcategoryId;
  final int? payeeId;
  final int amount;
  final int paymentMethodId;
  final int? recurrenceId;
  final String notes;

  Expense({
    this.id,
    required this.date,
    required this.categoryId,
    this.subcategoryId,
    this.payeeId,
    required this.amount,
    required this.paymentMethodId,
    this.recurrenceId,
    this.notes = '',
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'date': date.toIso8601String(),
    'category_id': categoryId,
    'subcategory_id': subcategoryId,
    'payee_id': payeeId,
    'amount': amount,
    'payment_method_id': paymentMethodId,
    'recurrence_id': recurrenceId,
    'notes': notes,
  };

  factory Expense.fromMap(Map<String, dynamic> map) => Expense(
    id: map['id'] as int?,
    date: DateTime.parse(map['date'] as String),
    categoryId: map['category_id'] as int,
    subcategoryId: map['subcategory_id'] as int?,
    payeeId: map['payee_id'] as int?,
    amount: map['amount'] as int,
    paymentMethodId: map['payment_method_id'] as int,
    recurrenceId: map['recurrence_id'] as int?,
    notes: map['notes'] as String,
  );
}
