import 'base_repo.dart';
import 'classification.dart';
import 'repo_tables.dart';

class ClassificationRepository extends BaseRepository<Classification> {
  ClassificationRepository() : super(Tables.classifications);

  // Get all classifications
  Future<List<Classification>> getAll() async =>
      await baseGetAll(fromMap: Classification.fromMap);

  // Insert a single classification
  Future<void> insert(Classification classification) async =>
      await baseInsert(classification, toMap: (item) => item.toMap());

  // Insert a list of classifications
  Future<void> insertAll(List<Classification> classifications) async =>
      await baseInsertAll(classifications, toMap: (item) => item.toMap());

  // Get a single classification by id
  Future<Classification?> getById(int id) async =>
      await baseGetById(id, fromMap: Classification.fromMap);

  // Update an existing classification by id
  Future<int> update(Classification classification, int id) async =>
      await baseUpdate(classification, toMap: (item) => item.toMap(), id: id);
}
