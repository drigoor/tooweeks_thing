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

  final classifications = <Classification>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadClassifications();
  }

  Future<void> _loadClassifications() async {
    isLoading.value = true;
    try {
      final data = await repo.getAll();
      classifications.assignAll(data);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addClassification(Classification classification) async {
    await repo.insert(classification);
    classifications.add(classification);
  }

  Future<bool> updateClassification(Classification updated) async {
    final count = await repo.update(updated, updated.id!);
    if (count == -1) {
      return false;
    }
    
    final index = classifications.indexWhere((c) => c.id == updated.id);
    if (index == -1) {
      return false;
    }
    classifications[index] = updated;

    return true;
  }

  Future<bool> deleteClassification(int id) async {
    final success = await repo.safeDelete(id);
    if (success) {
      classifications.removeWhere((c) => c.id == id);
    }
    return success;
  }

  Future<String> resetToBootstrap() async {
    final yamlString = await rootBundle.loadString('assets/bootstrap_data.yaml');
    final bootstrapData = parseClassificationsFromYaml(yamlString);

    await repo.deleteAll();
    await repo.insertAll(bootstrapData);
    await _loadClassifications();
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

  Map<String, dynamic> getStats() => _calculateStats();

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
