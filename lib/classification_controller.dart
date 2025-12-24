import 'dart:io';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

import 'classification.dart';
import 'classification_repo.dart';
import 'classification_yaml.dart';
import 'classification_yaml_writer.dart';
import 'utils.dart';

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

  Map<String, dynamic> getStats() => _calculateStats();

  Future<String> resetToBootstrap() async {
    final yamlString = await rootBundle.loadString('assets/bootstrap_data.yaml');
    final bootstrapData = parseClassificationsFromYaml(yamlString);

    await repo.deleteAll();
    await repo.insertAll(bootstrapData);
    await loadClassifications();
    return 'Database reset to bootstrap data (${bootstrapData.length} items)';
  }

  Future<String> exportToYaml() async {
    String timestamp = timestampForFilename();
    final filename = 'classifications_$timestamp.yaml';
    
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$filename');
    final yaml = classificationsToYaml(classifications);
    await file.writeAsString(yaml);
    
    return 'Exported ${classifications.length} items to $filename';
  }

  Future<bool> safeDelete(int id) async {
    final success = await repo.safeDelete(id);
    if (success) {
      classifications.removeWhere((c) => c.id == id);
    }
    return success;
  }

  Future<void> updateClassification(Classification updated) async {
    await repo.update(updated, updated.id!);
    final index = classifications.indexWhere((c) => c.id == updated.id);
    if (index != -1) {
      classifications[index] = updated;
    }
  }

  Map<String, dynamic> _calculateStats() {
    final kinds = <String>{};
    final parents = <int>{};
    int maxDepth = 0;

    for (final c in classifications) {
      kinds.add(c.kind);
      if (c.parentId != null) parents.add(c.parentId!);

      int depth = 0;
      Classification? current = c;
      while (current?.parentId != null) {
        depth++;
        current = classifications.firstWhereOrNull((p) => p.id == current!.parentId);
        if (maxDepth < depth) maxDepth = depth;
      }
    }

    return {
      'total': classifications.length,
      'kinds': kinds.toList()..sort(),
      'parentCount': parents.length,
      'orphanCount': classifications.length - parents.length,
      'maxDepth': maxDepth,
    };
  }
}
