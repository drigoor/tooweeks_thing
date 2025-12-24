import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'classification_controller.dart';
import 'classification_list_screen.dart';
import 'classification_repo.dart';
import 'classification_yaml.dart';
import 'database_helper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!Platform.isAndroid && !Platform.isIOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  final dbHelper = DatabaseHelper();
  await dbHelper.database;

  final classificationRepo = ClassificationRepository();
  final isEmpty = await classificationRepo.isEmpty();
  if (isEmpty) {
    final yamlString = await rootBundle.loadString('assets/bootstrap_data.yaml');
    final classifications = parseClassificationsFromYaml(yamlString);
    await classificationRepo.insertAll(classifications);
  }

  // Inject controller for dependency injection
  Get.put(ClassificationController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Classifications',
      theme: ThemeData(useMaterial3: true),
      home: const ClassificationListScreen(),
    );
  }
}
