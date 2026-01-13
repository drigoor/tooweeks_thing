import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'classification.dart';
import 'classification_controller.dart';
import 'classification_edit_screen.dart';
import 'classification_sceen_utils.dart';
import 'utils.dart';

class ClassificationTreeScreen extends GetView<ClassificationController> {
  const ClassificationTreeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Classifications'),
        actions: _getActions(),
      ),
      body: Obx(() => _buildBody()),
    );
  }

  List<Widget>? _getActions() => [
    Obx(
      () => PopupMenuButton<String>(
        enabled: !controller.isLoading.value,
        onSelected: _handleAction,
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'add',
            child: Row(children: [Icon(Icons.add), SizedBox(width: 8), Text('Add New')]),
          ),
          const PopupMenuItem(
            value: 'reset',
            child: Row(children: [Icon(Icons.restart_alt), SizedBox(width: 8), Text('Reset')]),
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
      ),
    ),
  ];

  Future<void> _handleAction(String value) async {
    switch (value) {
      case 'add':
        final classification = Classification(id: null, kind: '', name: '', parentId: null);
        Get.to(() => ClassificationEditScreen(classification: classification));
        break;

      case 'reset':
        final confirmed = await confirmAction(
          title: 'Reset Database?',
          message: '\n>>> !!! DONT DO IT !!! <<<\n\nAnd what about the expenses already in the database?\n\nThis will delete ALL classifications and reload the bootstrap data. This action cannot be undone.',
          confirmText: 'Reset',
        );
        if (confirmed) {
          final message = await controller.resetToBootstrap();
          Get.snackbar('Success', message);
        }
        break;

      case 'export':
        final message = await controller.exportToYaml();
        Get.snackbar('Success', message);
        break;

      case 'stats':
        _showStatsDialog();
        break;
    }
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
        actions: [TextButton(onPressed: Get.back, child: const Text('Close'))],
      ),
    );
  }

  Widget _buildBody() {
    if (controller.isLoading.value) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.classifications.isEmpty) {
      return const Center(child: Text('No classifications found.'));
    }

    return _buildTree();
  }

  Widget _buildTree() {
    final all = controller.classifications;
    final classificationsWithSameKind = all.map((c) => c.kind).toSet().toList()
      ..sort();

    return ListView.builder(
      itemCount: classificationsWithSameKind.length,
      itemBuilder: (context, index) {
        final kind = classificationsWithSameKind[index];
        final kindItems = all.where((c) => c.kind == kind).toList();

        // Roots within this kind
        final roots = kindItems.where((c) => c.parentId == null).toList();

        return ExpansionTile(
          leading: Icon(getKindIcon(kind)),
          title: GestureDetector(
            onTap: () {},
            child: Text(kind),
          ),
          children: roots.map((root) => _buildNode(root, kindItems)).toList(),
        );
      },
    );
  }

  Widget _buildNode(
    Classification classification,
    List<Classification> sameKindItems,
  ) {
    final children = sameKindItems
        .where((c) => c.parentId == classification.id)
        .toList();

    if (children.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(32.0, 0.0, 0.0, 0.0),
        child: ListTile(
          leading: const Icon(Icons.label_outline),
          title: Text(classification.name),
          onTap: () => Get.to(() => ClassificationEditScreen(classification: classification)),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(32.0, 0.0, 0.0, 0.0),
      child: ExpansionTile(
        leading: Icon(getCategoryIcon(classification.name)),
        title: GestureDetector(
          onTap: () {},
          child: Text(classification.name),
        ),
        children: children
            .map((child) => _buildNode(child, sameKindItems))
            .toList(),
      ),
    );
  }
}
