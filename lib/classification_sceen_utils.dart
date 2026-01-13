import 'package:flutter/material.dart';

const Map<String, IconData> _categoryIcons = {
  'comida': Icons.restaurant,
  'transportes': Icons.directions_transit,
  'contas': Icons.account_balance,
  'carro': Icons.directions_car,
  'outra': Icons.more_horiz,
};

IconData getCategoryIcon(String category) =>
    _categoryIcons[category.toLowerCase()] ?? Icons.category_outlined;

const Map<String, IconData> _kindIcons = {
  'expense_category': Icons.folder_outlined,
  'payment_method': Icons.payment_outlined,
  'payee': Icons.business,
  'recurrence': Icons.repeat_outlined,
};

IconData getKindIcon(String kind) =>
    _kindIcons[kind.toLowerCase()] ?? Icons.folder_outlined;
