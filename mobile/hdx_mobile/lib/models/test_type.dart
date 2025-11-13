import 'package:flutter/material.dart';

class TestType {
  final String id;
  final String name;
  final String description;
  final String icon;
  final Color color;

  TestType({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
  });

  factory TestType.fromJson(Map<String, dynamic> json) {
    return TestType(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      icon: json['icon'] as String? ?? 'medical_services',
      color: _parseColor(json['color'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'color': color.toARGB32().toRadixString(16).substring(2, 8), // Remove alpha channel, keep RGB
    };
  }

  static Color _parseColor(String? colorHex) {
    if (colorHex == null || colorHex.isEmpty) {
      return Colors.blue;
    }
    try {
      return Color(int.parse(colorHex, radix: 16));
    } catch (e) {
      return Colors.blue;
    }
  }
}

