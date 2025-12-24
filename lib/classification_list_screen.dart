import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'classification.dart';
import 'classification_controller.dart';
import 'classification_detail_screen.dart';
import 'utils.dart';

class ClassificationListScreen extends GetView<ClassificationController> {
  const ClassificationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Classifications'),
        actions: [
          Obx(() => PopupMenuButton<String>(
            enabled: !controller.isLoading.value,
            onSelected: _handleAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                  value: 'add',
                  child: Row(children: [Icon(Icons.add), SizedBox(width: 8), Text('Add New')])
              ),
              const PopupMenuItem(
                  value: 'reset',
                  child: Row(children: [Icon(Icons.restart_alt), SizedBox(width: 8), Text('Reset DB')])
              ),
              const PopupMenuItem(
                  value: 'export',
                  child: Row(children: [Icon(Icons.download), SizedBox(width: 8), Text('Export')])
              ),
              const PopupMenuItem(
                  value: 'stats',
                  child: Row(children: [Icon(Icons.bar_chart), SizedBox(width: 8), Text('Stats')])
              ),
            ],
          )),
        ],
      ),
      body: Obx(() => _buildBody()),
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

  Future<void> _handleAction(String value) async {
    switch (value) {
      case 'add':
        _openDetails(Classification(id: null, kind: '', name: '', parentId: null));
        break;

      case 'reset':
        final confirmed = await confirmAction(
          title: 'Reset Database?',
          message: 'This will delete ALL classifications and reload the bootstrap data. This action cannot be undone.',
          confirmText: 'Reset',
        );
        if (confirmed) {
          final message = await controller.resetToBootstrap();
          _showSuccess(message);
        }
        break;

      case 'export':
        final message = await controller.exportToYaml();
        _showSuccess(message);
        break;

      case 'stats':
        _showStatsDialog();
        break;
    }
  }


  void _openDetails(Classification c) {
    Get.to(() => ClassificationDetailScreen(classification: c));
  }

  void _showStatsDialog() {
    final stats = controller.getStats();
    Get.dialog(
      AlertDialog(
        title: const Text('📊 Classification Stats'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Total: ${stats['total']} classifications'),
              Text('Kinds: ${stats['kinds'].join(", ")}'),
              Text('Parents: ${stats['parentCount']}'),
              Text('Orphans: ${stats['orphanCount']}'),
              Text('Deepest level: ${stats['maxDepth']}'),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Close')),
        ],
      ),
    );
  }

  void _showSuccess(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 4),
    );
  }
}
