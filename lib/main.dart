import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'classification.dart';
import 'classification_repo.dart';
import 'classification_yaml.dart';
import 'database_helper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Optional: support desktop with sqflite_common_ffi
  if (!Platform.isAndroid && !Platform.isIOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Ensure DB/tables exist
  final dbHelper = DatabaseHelper();
  await dbHelper.database;

  // Create a single repository instance
  final classificationRepo = ClassificationRepository();

  // Bootstrap if classifications table is empty
  final isEmpty = await classificationRepo.isEmpty();
  if (isEmpty) {
    final yamlString = await rootBundle.loadString('assets/bootstrap_data.yaml');
    final classifications = parseClassificationsFromYaml(yamlString);
    await classificationRepo.insertAll(classifications);
  }

  runApp(MyApp(classificationRepo: classificationRepo));
}

class MyApp extends StatelessWidget {
  final ClassificationRepository classificationRepo;

  const MyApp({super.key, required this.classificationRepo});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Classifications',
      theme: ThemeData(useMaterial3: true),
      home: ClassificationListScreen(repo: classificationRepo),
    );
  }
}

class ClassificationListScreen extends StatefulWidget {
  final ClassificationRepository repo;

  const ClassificationListScreen({super.key, required this.repo});

  @override
  State<ClassificationListScreen> createState() =>
      _ClassificationListScreenState();
}

class _ClassificationListScreenState extends State<ClassificationListScreen> {
  late Future<List<Classification>> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _future = widget.repo.getAll();
  }

  Future<void> _openDetails(Classification c) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ClassificationDetailScreen(
          repo: widget.repo,
          classification: c,
        ),
      ),
    );

    if (changed == true) {
      setState(_reload);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Classifications'),
      ),
      body: FutureBuilder<List<Classification>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          final data = snapshot.data ?? [];
          if (data.isEmpty) {
            return const Center(
              child: Text('No classifications found.'),
            );
          }

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final c = data[index];
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
        },
      ),
    );
  }
}

class ClassificationDetailScreen extends StatefulWidget {
  final ClassificationRepository repo;
  final Classification classification;

  const ClassificationDetailScreen({
    super.key,
    required this.repo,
    required this.classification,
  });

  @override
  State<ClassificationDetailScreen> createState() =>
      _ClassificationDetailScreenState();
}

class _ClassificationDetailScreenState
    extends State<ClassificationDetailScreen> {
  late TextEditingController _kindController;
  late TextEditingController _nameController;
  late TextEditingController _parentIdController;

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

  Future<void> _save() async {
    final id = widget.classification.id;
    if (id == null) return;

    final kind = _kindController.text.trim();
    final name = _nameController.text.trim();
    final parentIdText = _parentIdController.text.trim();
    final parentId =
    parentIdText.isEmpty ? null : int.tryParse(parentIdText);

    final updated = Classification(
      id: id,
      kind: kind,
      parentId: parentId,
      name: name,
    );

    await widget.repo.update(updated, id);
    if (!mounted) return;
    Navigator.pop(context, true);
  }


  Future<void> _delete() async {
    final id = widget.classification.id;
    if (id == null) return;

    final success = await widget.repo.safeDelete(id);
    if (!success) {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Cannot delete'),
          content: Text(
            'This classification has subcategories and cannot be deleted. '
                'Please delete or reassign them first.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    // Success - pop and refresh list
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.classification;

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit: ${c.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _delete,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _kindController,
              decoration: const InputDecoration(
                labelText: 'Kind',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
              ),
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
              onPressed: _save,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
