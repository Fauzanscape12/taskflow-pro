import 'package:flutter/material.dart';

/// Model Kategori Tugas
class TaskCategory {
  final String id;
  final String name;
  final String icon;
  final String color;
  final int order;

  TaskCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.order = 0,
  });

  /// Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
      'order': order,
    };
  }

  /// Create from Map
  factory TaskCategory.fromMap(Map<String, dynamic> map) {
    return TaskCategory(
      id: map['id'] as String,
      name: map['name'] as String,
      icon: map['icon'] as String,
      color: map['color'] as String,
      order: map['order'] as int? ?? 0,
    );
  }

  /// Get Color from hex string
  Color get colorValue {
    final buffer = StringBuffer();
    if (color.length == 7 && color[0] == '#') {
      buffer.write('0xFF');
      buffer.write(color.substring(1));
    } else if (color.length == 6) {
      buffer.write('0xFF');
      buffer.write(color);
    }
    return Color(int.parse(buffer.toString()));
  }

  /// Copy with
  TaskCategory copyWith({
    String? id,
    String? name,
    String? icon,
    String? color,
    int? order,
  }) {
    return TaskCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      order: order ?? this.order,
    );
  }
}

/// Predefined Categories
class PredefinedCategories {
  static final List<TaskCategory> all = [
    TaskCategory(
      id: 'work',
      name: 'Pekerjaan',
      icon: '💼',
      color: '#3B82F6',
      order: 0,
    ),
    TaskCategory(
      id: 'personal',
      name: 'Pribadi',
      icon: '👤',
      color: '#10B981',
      order: 1,
    ),
    TaskCategory(
      id: 'shopping',
      name: 'Belanja',
      icon: '🛒',
      color: '#F59E0B',
      order: 2,
    ),
    TaskCategory(
      id: 'health',
      name: 'Kesehatan',
      icon: '🏥',
      color: '#EF4444',
      order: 3,
    ),
    TaskCategory(
      id: 'sport',
      name: 'Olahraga',
      icon: '⚽',
      color: '#8B5CF6',
      order: 4,
    ),
    TaskCategory(
      id: 'study',
      name: 'Belajar',
      icon: '📚',
      color: '#EC4899',
      order: 5,
    ),
    TaskCategory(
      id: 'movie',
      name: 'Film',
      icon: '🎬',
      color: '#6366F1',
      order: 6,
    ),
    TaskCategory(
      id: 'music',
      name: 'Musik',
      icon: '🎵',
      color: '#F97316',
      order: 7,
    ),
    TaskCategory(
      id: 'travel',
      name: 'Travel',
      icon: '✈️',
      color: '#14B8A6',
      order: 8,
    ),
    TaskCategory(
      id: 'finance',
      name: 'Keuangan',
      icon: '💰',
      color: '#22C55E',
      order: 9,
    ),
    TaskCategory(
      id: 'food',
      name: 'Makanan',
      icon: '🍽️',
      color: '#EAB308',
      order: 10,
    ),
    TaskCategory(
      id: 'gaming',
      name: 'Gaming',
      icon: '🎮',
      color: '#A855F7',
      order: 11,
    ),
    TaskCategory(
      id: 'social',
      name: 'Sosial',
      icon: '👥',
      color: '#F43F5E',
      order: 12,
    ),
    TaskCategory(
      id: 'diy',
      name: 'DIY',
      icon: '🔧',
      color: '#64748B',
      order: 13,
    ),
  ];

  /// Get category by ID
  static TaskCategory? getById(String id) {
    try {
      return all.firstWhere((cat) => cat.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get all category icons for picker
  static const List<Map<String, String>> categoryIcons = [
    {'emoji': '💼', 'name': 'Pekerjaan'},
    {'emoji': '👤', 'name': 'Pribadi'},
    {'emoji': '🛒', 'name': 'Belanja'},
    {'emoji': '🏥', 'name': 'Kesehatan'},
    {'emoji': '⚽', 'name': 'Olahraga'},
    {'emoji': '📚', 'name': 'Belajar'},
    {'emoji': '🎬', 'name': 'Film'},
    {'emoji': '🎵', 'name': 'Musik'},
    {'emoji': '✈️', 'name': 'Travel'},
    {'emoji': '💰', 'name': 'Keuangan'},
    {'emoji': '🍽️', 'name': 'Makanan'},
    {'emoji': '🎮', 'name': 'Gaming'},
    {'emoji': '👥', 'name': 'Sosial'},
    {'emoji': '🔧', 'name': 'DIY'},
    {'emoji': '🏠', 'name': 'Rumah'},
    {'emoji': '🚗', 'name': 'Kendaraan'},
    {'emoji': '💻', 'name': 'Teknologi'},
    {'emoji': '🎨', 'name': 'Seni'},
    {'emoji': '📷', 'name': 'Foto'},
    {'emoji': '🌱', 'name': 'Tanaman'},
    {'emoji': '🐕', 'name': 'Hewan'},
    {'emoji': '👶', 'name': 'Keluarga'},
    {'emoji': '❤️', 'name': 'Romantis'},
    {'emoji': '🎉', 'name': 'Acara'},
    {'emoji': '📝', 'name': 'Catatan'},
    {'emoji': '💡', 'name': 'Ide'},
    {'emoji': '⭐', 'name': 'Favorit'},
  ];

  /// Get all category colors for picker
  static const List<Map<String, String>> categoryColors = [
    {'color': '#3B82F6', 'name': 'Blue'},
    {'color': '#10B981', 'name': 'Green'},
    {'color': '#F59E0B', 'name': 'Amber'},
    {'color': '#EF4444', 'name': 'Red'},
    {'color': '#8B5CF6', 'name': 'Purple'},
    {'color': '#EC4899', 'name': 'Pink'},
    {'color': '#6366F1', 'name': 'Indigo'},
    {'color': '#F97316', 'name': 'Orange'},
    {'color': '#14B8A6', 'name': 'Teal'},
    {'color': '#22C55E', 'name': 'Emerald'},
    {'color': '#EAB308', 'name': 'Yellow'},
    {'color': '#A855F7', 'name': 'Violet'},
    {'color': '#F43F5E', 'name': 'Rose'},
    {'color': '#64748B', 'name': 'Slate'},
    {'color': '#0EA5E9', 'name': 'Sky'},
    {'color': '#84CC16', 'name': 'Lime'},
  ];
}
