import 'package:flutter/material.dart';
import 'package:get/get.dart';

String formatAmount(int amountCents) {
  final euros = amountCents ~/ 100;
  final cents = (amountCents % 100).toString().padLeft(2, '0');
  return '€$euros.$cents';
}

// Generate timestamped filename: classifications_2025-12-24_01-25.yaml
String timestampForFilename() {
  final now = DateTime.now();
  final year = now.toIso8601String().split('T')[0];
  final hour = now.hour.toString().padLeft(2, '0');
  final minutes = now.minute.toString().padLeft(2, '0');
  final second = now.second.toString().padLeft(2, '0');
  return '${year}_$hour-$minutes-$second';
}

Future<bool> confirmAction({
  required String title,
  required String message,
  String confirmText = 'Confirm',
  Color confirmColor = Colors.red,
}) async {
  return await Get.dialog<bool>(
        AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.warning, color: Colors.orange),
              const SizedBox(width: 8),
              Text(title),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false), // Cancel
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: confirmColor),
              onPressed: () => Get.back(result: true), // Confirm
              child: Text(confirmText),
            ),
          ],
        ),
      ) ??
      false; // Default to false if dialog dismissed
}
