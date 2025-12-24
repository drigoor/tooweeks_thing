import 'package:get/get.dart';

import 'classification.dart';
import 'classification_repo.dart';

class ClassificationController extends GetxController {
  final ClassificationRepository repo = ClassificationRepository();

  final RxList<Classification> classifications = <Classification>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadClassifications();
  }

  Future<void> loadClassifications() async {
    isLoading.value = true;
    try {
      final data = await repo.getAll();
      classifications.assignAll(data);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Future<void> refresh() => loadClassifications();

  Future<bool> safeDelete(int id) async {
    final success = await repo.safeDelete(id);
    if (success) {
      classifications.removeWhere((c) => c.id == id);
    }
    return success;
  }

  Future<void> updateClassification(Classification updated) async {
    await repo.update(updated, updated.id!);
    // Update the reactive list
    final index = classifications.indexWhere((c) => c.id == updated.id);
    if (index != -1) {
      classifications[index] = updated;
    }
  }
}
