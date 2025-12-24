import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'classification.dart';
import 'classification_controller.dart';
import 'classification_detail_screen.dart';

class ClassificationListScreen extends GetView<ClassificationController> {
  const ClassificationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Classifications'),
        actions: [
          Obx(() => IconButton(  // Show loading spinner in button
            icon: controller.isLoading.value
                ? const SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(strokeWidth: 2)
            )
                : const Icon(Icons.refresh),
            onPressed: controller.refresh,
          )),
        ],
      ),
      body: Obx(() => _buildBody()),  // ← Obx() around the body
    );
  }

  Widget _buildBody() {
    if (controller.isLoading.value) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.classifications.isEmpty) {
      return const Center(child: Text('No classifications found.'));
    }

    return ListView.builder(
      itemCount: controller.classifications.length,
      itemBuilder: (context, index) {
        final c = controller.classifications[index];
        final subtitle = StringBuffer()
          ..write('kind: ${c.kind}');
        if (c.parentId != null) {
          subtitle.write('  parentId: ${c.parentId}');
        }

        return ListTile(
          title: Text(c.name),
          subtitle: Text(subtitle.toString()),
          onTap: () => _openDetails(c),
        );
      },
    );
  }

  void _openDetails(Classification c) {
    Get.to(() => ClassificationDetailScreen(classification: c));
  }
}
