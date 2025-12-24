import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'home_screen.dart';
import 'classification_controller.dart';
import 'classification_repo.dart';
import 'classification_yaml.dart';
import 'database_helper.dart';
import 'expense_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // support desktop database support
  if (!Platform.isAndroid && !Platform.isIOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  final dbHelper = DatabaseHelper();
  await dbHelper.database;

  final classificationRepo = ClassificationRepository();
  final isEmpty = await classificationRepo.isEmpty();
  if (isEmpty) {
    final yamlString = await rootBundle.loadString(
      'assets/bootstrap_data.yaml',
    );
    final classifications = parseClassificationsFromYaml(yamlString);
    await classificationRepo.insertAll(classifications);
  }

  Get.put(ClassificationController());
  Get.put(ExpenseController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expenses Things',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
      home: const HomeScreen(),
    );
  }
}
