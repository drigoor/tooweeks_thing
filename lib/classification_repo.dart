import 'base_repo.dart';
import 'classification.dart';
import 'repo_tables.dart';

class ClassificationRepository extends BaseRepository<Classification> {
  ClassificationRepository() : super(Tables.classifications);

  Future<List<Classification>> getAll() async =>
      await baseGetAll(fromMap: Classification.fromMap);

  Future<void> insert(Classification classification) async =>
      await baseInsert(classification, toMap: (item) => item.toMap());

  Future<void> insertAll(List<Classification> classifications) async =>
      await baseInsertAll(classifications, toMap: (item) => item.toMap());

  Future<Classification?> getById(int id) async =>
      await baseGetById(id, fromMap: Classification.fromMap);

  Future<int> update(Classification classification, int id) async =>
      await baseUpdate(classification, toMap: (item) => item.toMap(), id: id);
}
