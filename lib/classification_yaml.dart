import 'package:yaml/yaml.dart';

import 'classification.dart';

List<Classification> parseClassificationsFromYaml(String yamlString) {
  final doc = loadYaml(yamlString);

  if (doc is! YamlMap) {
    throw FormatException('Root of YAML must be a map.');
  }

  final List<Classification> result = [];
  int idCounter = 1;

  doc.forEach((sectionKey, sectionValue) {
    if (sectionKey is! String) {
      throw FormatException('All top-level keys must be strings.');
    }

    if (sectionValue is YamlMap) {
      // Map of lists → categories with subcategories
      sectionValue.forEach((key, value) {
        if (key is! String || key.trim().isEmpty) {
          throw FormatException(
            'Category name in "$sectionKey" must be a non-empty string.',
          );
        }
        if (value is! YamlList) {
          throw FormatException(
            'Value of "$key" in "$sectionKey" must be a list.',
          );
        }

        final parentId = idCounter++;
        result.add(Classification(id: parentId, kind: sectionKey, name: key));

        for (final sub in value) {
          if (sub is! String || sub.trim().isEmpty) {
            throw FormatException(
              'Subcategory of "$key" must be a non-empty string.',
            );
          }
          result.add(
            Classification(
              id: idCounter++,
              kind: sectionKey,
              parentId: parentId,
              name: sub,
            ),
          );
        }
      });
    } else if (sectionValue is YamlList) {
      // Flat list → each item becomes a classification with parentId = null
      for (final item in sectionValue) {
        if (item is! String || item.trim().isEmpty) {
          throw FormatException(
            'Item in "$sectionKey" must be a non-empty string.',
          );
        }
        result.add(
          Classification(id: idCounter++, kind: sectionKey, name: item),
        );
      }
    } else {
      throw FormatException('Section "$sectionKey" must be a map or a list.');
    }
  });

  return result;
}
