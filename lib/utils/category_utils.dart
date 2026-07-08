import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

/// Tiện ích dùng chung cho icon và màu danh mục.
class CategoryUtils {
  CategoryUtils._();

  static IconData iconFromCode(int codePoint) {
    return IconData(codePoint, fontFamily: 'IconlyLight', fontPackage: 'iconly');
  }

  static Color colorFromHex(String hexColor, {Color fallback = Colors.orange}) {
    final hex = hexColor.replaceAll('#', '');
    try {
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return fallback;
    }
  }

  static IconData iconForType(String type) {
    return type == 'income' ? IconlyBold.download : IconlyBold.upload;
  }
}
