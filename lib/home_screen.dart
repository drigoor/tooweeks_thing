import 'package:flutter/material.dart';

import 'classification_list_screen.dart';
import 'expense_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Expenses App'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.receipt_long), text: 'Expenses'),
              Tab(icon: Icon(Icons.category), text: 'Categories'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            ExpenseListScreen(),
            ClassificationListScreen(),
          ],
        ),
      ),
    );
  }
}
