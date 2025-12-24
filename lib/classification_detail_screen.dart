import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'classification.dart';
import 'classification_controller.dart';

class ClassificationDetailScreen extends StatefulWidget {
  final Classification classification;

  const ClassificationDetailScreen({super.key, required this.classification});

  @override
  State<ClassificationDetailScreen> createState() =>
      _ClassificationDetailScreenState();
}

class _ClassificationDetailScreenState
    extends State<ClassificationDetailScreen> {
  late final TextEditingController _kindController;
  late final TextEditingController _nameController;
  late final TextEditingController _parentIdController;

  @override
  void initState() {
    super.initState();
    _kindController = TextEditingController(text: widget.classification.kind);
    _nameController = TextEditingController(text: widget.classification.name);
    _parentIdController = TextEditingController(
      text: widget.classification.parentId?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _kindController.dispose();
    _nameController.dispose();
    _parentIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ClassificationController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit: ${widget.classification.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _delete(controller),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _kindController,
              decoration: const InputDecoration(labelText: 'Kind'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _parentIdController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Parent ID (optional)',
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => _save(controller),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save(ClassificationController controller) async {
    final id = widget.classification.id!;
    final kind = _kindController.text.trim();
    final name = _nameController.text.trim();
    final parentIdText = _parentIdController.text.trim();
    final parentId = parentIdText.isEmpty ? null : int.tryParse(parentIdText);

    final updated = Classification(
      id: id,
      kind: kind,
      parentId: parentId,
      name: name,
    );

    await controller.updateClassification(updated);
    Get.back();
  }

  Future<void> _delete(ClassificationController controller) async {
    final success = await controller.safeDelete(widget.classification.id!);
    if (!success) {
      Get.dialog(
        AlertDialog(
          title: const Text('Cannot delete'),
          content: const Text(
            'This classification has subcategories and cannot be deleted. '
            'Please delete or reassign them first.',
          ),
          actions: [TextButton(onPressed: Get.back, child: const Text('OK'))],
        ),
      );
      return;
    }
    Get.back();
  }
}
