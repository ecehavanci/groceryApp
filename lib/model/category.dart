import 'package:flutter/material.dart';

class Category {
  final String category;
  final Color color;

  const Category(this.category, this.color);
}

enum Categories {
  vegetables,
  fruit,
  meat,
  dairy,
  carbs,
  sweets,
  spices,
  convenience,
  hygiene,
  other
}
