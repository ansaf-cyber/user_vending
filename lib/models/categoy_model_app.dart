import 'package:flutter/material.dart';

class CategoryModelApp {
  final String id;
  final String name;
  final String ownerId;

  /// PNG image URL from Firebase Storage
  final String? pngUrl;

  /// Local file path for cached image
  final String? localFilePath;

  /// Cached PNG URL to avoid re-downloading
  final String? cachedPngUrl;

  /// Color value for PNG tinting (stored as int, converted to/from Color)
  final int pngColor;

  /// Optional label for the category
  final String? label;

  CategoryModelApp({
    required this.id,
    required this.name,
    required this.ownerId,
    this.pngUrl,
    this.localFilePath,
    this.cachedPngUrl,
    this.pngColor = 0xFF2196F3, // Default blue color
    this.label,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'ownerId': ownerId,
      'pngUrl': pngUrl,
      'localFilePath': localFilePath,
      'cachedPngUrl': cachedPngUrl,
      'pngColor': pngColor,
      'label': label,
    };
  }

  factory CategoryModelApp.fromMap(Map<String, dynamic> map) {
    // Backward compatibility: check for old SVG fields
    if (map['pngUrl'] == null && map['svgType'] != null) {
      // Old SVG data format - return with null pngUrl (will show default icon)
      return CategoryModelApp(
        id: map['id'] ?? '',
        name: map['name'] ?? '',
        ownerId: map['ownerId'] ?? '',
        pngUrl: null,
        localFilePath: map['localFilePath'],
        cachedPngUrl: map['cachedPngUrl'],
        pngColor: 0xFF2196F3,
      );
    }

    // Backward compatibility: check for even older icon fields
    if (map['pngUrl'] == null && map['iconCodePoint'] != null) {
      return CategoryModelApp(
        id: map['id'] ?? '',
        name: map['name'] ?? '',
        ownerId: map['ownerId'] ?? '',
        pngUrl: null,
        localFilePath: map['localFilePath'],
        cachedPngUrl: map['cachedPngUrl'],
        pngColor: 0xFF2196F3,
      );
    }

    return CategoryModelApp(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      ownerId: map['ownerId'] ?? '',
      pngUrl: map['pngUrl'],
      localFilePath: map['localFilePath'],
      cachedPngUrl: map['cachedPngUrl'],
      pngColor: map['pngColor'] ?? 0xFF2196F3,
      label: map['label'],
    );
  }

  CategoryModelApp copyWith({
    String? id,
    String? name,
    String? ownerId,
    String? pngUrl,
    String? localFilePath,
    String? cachedPngUrl,
    int? pngColor,
    String? label,
  }) {
    return CategoryModelApp(
      id: id ?? this.id,
      name: name ?? this.name,
      ownerId: ownerId ?? this.ownerId,
      pngUrl: pngUrl ?? this.pngUrl,
      localFilePath: localFilePath ?? this.localFilePath,
      cachedPngUrl: cachedPngUrl ?? this.cachedPngUrl,
      pngColor: pngColor ?? this.pngColor,
      label: label ?? this.label,
    );
  }

  /// Get Color object from stored int value
  Color get color => Color(pngColor);
}
