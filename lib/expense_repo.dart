import 'base_repo.dart';
import 'expense.dart';
import 'repo_tables.dart';

class ExpenseRepository extends BaseRepository<Expense> {
  ExpenseRepository() : super(Tables.expenses);

  Future<List<Expense>> getAll() async =>
      await baseGetAll(fromMap: Expense.fromMap);

  Future<void> insert(Expense expense) async =>
      await baseInsert(expense, toMap: (item) => item.toMap());

  Future<void> insertAll(List<Expense> expenses) async =>
      await baseInsertAll(expenses, toMap: (item) => item.toMap());

  Future<Expense?> getById(int id) async =>
      await baseGetById(id, fromMap: Expense.fromMap);

  Future<int> update(Expense expense, int id) async =>
      await baseUpdate(expense, toMap: (item) => item.toMap(), id: id);
}
