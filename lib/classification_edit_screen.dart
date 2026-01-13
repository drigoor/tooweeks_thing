import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'classification.dart';
import 'classification_controller.dart';
import 'utils.dart';


class ClassificationEditScreen extends StatefulWidget {
  final Classification classification;

  const ClassificationEditScreen({super.key, required this.classification});

  @override
  State<ClassificationEditScreen> createState() =>
      _ClassificationEditScreenState();
}

class _ClassificationEditScreenState extends State<ClassificationEditScreen> {
  late final ClassificationController controller;
  late final TextEditingController kindCtrl;
  late final TextEditingController nameCtrl;

  @override
  void initState() {
    super.initState();
    controller = Get.find<ClassificationController>();
    kindCtrl = TextEditingController(text: widget.classification.kind);
    nameCtrl = TextEditingController(text: widget.classification.name);
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    kindCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final classification = widget.classification;

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Classification: ${classification.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _delete(),
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () => _save(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: kindCtrl,
              decoration: const InputDecoration(labelText: 'Kind'),
            ),
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 32),
            Text(
              'id: ${classification.id}    parent id: ${classification.parentId ?? '-'}',
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final classification = widget.classification;

    final updated = Classification(
      id: classification.id,
      kind: kindCtrl.text,
      name: nameCtrl.text,
      parentId: classification.parentId,
    );
    final success = await controller.updateClassification(updated);
    if (success) {
      Get.back();
      Get.snackbar(
        'Success',
        'Updated \'${updated.kind}: ${updated.name}\'',
      );
    } else {
      Get.snackbar('Error', 'Update failed');
    }
  }

  Future<void> _delete() async {
    // In detail screen _delete():
    final confirmed = await confirmAction(
      title: 'Delete Classification?',
      message: 'This will permanently remove "${widget.classification.name}".',
      confirmText: 'Delete',
    );
    if (confirmed) {
      final safeToDelete = await controller.deleteClassification(
        widget.classification.id!,
      );
      if (!safeToDelete) {
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
}
