class Classification {
  final int? id;
  final String kind;
  final int? parentId;
  final String name;

  const Classification({
    this.id,
    required this.kind,
    this.parentId,
    required this.name,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'kind': kind,
      'parent_id': parentId,
      'name': name,
    };
  }

  factory Classification.fromMap(Map<String, dynamic> map) {
    final kind = map['kind'] as String;
    final name = map['name'] as String;

    if (kind.isEmpty) {
      throw ArgumentError('Kind must not be empty');
    }
    if (name.isEmpty) {
      throw ArgumentError('Name must not be empty');
    }

    return Classification(
      id: map['id'] as int?,
      kind: kind,
      parentId: map['parent_id'] as int?,
      name: name,
    );
  }
}
