import 'classification.dart';

String classificationsToYaml(List<Classification> classifications) {
  // Group by kind
  final Map<String, Map<String, List<String>>> yamlStructure = {};

  for (final classification in classifications) {
    final kind = classification.kind;

    yamlStructure.putIfAbsent(kind, () => <String, List<String>>{});
    final kindMap = yamlStructure[kind]!;

    if (classification.parentId == null) {
      // Top-level parent
      kindMap[classification.name] ??= [];
    } else {
      // Child - add to parent's list
      final parentName = classifications
          .firstWhere((c) => c.id == classification.parentId)
          .name;
      kindMap[parentName] ??= [];
      kindMap[parentName]!.add(classification.name);
    }
  }

  // Build YAML string
  final buffer = StringBuffer();

  yamlStructure.forEach((kind, categories) {
    buffer.writeln('$kind:');

    // Check if this kind has ANY hierarchical structure (parent with children)
    final hasAnyHierarchy = categories.values.any((children) => children.isNotEmpty);

    if (!hasAnyHierarchy) {
      // Flat list → use block list syntax (- Item)
      for (var name in categories.keys) {
        buffer.writeln('  - $name');
      }
    } else {
      // Hierarchical kind → use parent: [children] OR parent: [] syntax
      categories.forEach((parentName, children) {
        if (children.isEmpty) {
          buffer.writeln('  $parentName: []');  // ← Exactly what you want!
        } else {
          final childrenYaml = '[${children.map((c) => c).join(', ')}]';
          buffer.writeln('  $parentName: $childrenYaml');
        }
      });
    }

    buffer.writeln(); // Empty line between kinds
  });

  return buffer.toString().trim();
}
