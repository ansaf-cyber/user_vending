import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:user/models/categoy_model_app.dart';
import 'package:user/models/product_tag_model.dart';

class ProductModel {
  final String? id;
  final String? autoId;
  final String name;
  final double price;
  final int stock;
  final String imageUrl;

  final List<String> slots;
  final Map<String, int> stockPerSlot;
  final Map<String, String> slotType;

  final int slot;
  final CategoryModelApp? category;

  // NEW FIELDS
  final bool isMerged; // Example: true if multiple slots merged
  final List<String> mergedSlotIds; // Example: ["01", "11", "12"]

  final int mainwarehouseqty;
  final double? pricePerMachine;
  final String? categoryId;
  final List<String> productTagIds;
  final List<ProductTagModel> tags;
  final String? descriptionPerMachine;
  final double? cutPricePerMachine;
  final DateTime? expiryDate;
  final String? localFilePath;
  final String?
  cachedImageUrl; // URL of the cached image to avoid re-downloading
  final List<String>
  blockedSlots; // NEW: Slots that are blocked due to dispense error

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    this.autoId,
    this.pricePerMachine = 0,
    required this.imageUrl,
    this.slots = const [],
    this.stockPerSlot = const {},
    required this.slot,
    this.category,
    this.cutPricePerMachine,
    this.descriptionPerMachine,
    this.slotType = const {},

    // NEW
    this.isMerged = false,
    this.mergedSlotIds = const [],

    this.mainwarehouseqty = 0,

    this.categoryId,
    this.productTagIds = const [],
    this.tags = const [],
    this.expiryDate,
    this.localFilePath,
    this.cachedImageUrl,
    this.blockedSlots = const [],
  });

  double get effectivePrice => (pricePerMachine != null && pricePerMachine != 0)
      ? pricePerMachine!
      : price;

  // Total stock
  int get totalStock {
    if (stockPerSlot.isEmpty) return stock;
    return stockPerSlot.values.fold(0, (sum, q) => sum + q);
  }

  // Stock for specific slot
  int getStockForSlot(String slotNumber) => stockPerSlot[slotNumber] ?? 0;

  // Primary slot
  String get primarySlot => slots.isNotEmpty ? slots.first : slot.toString();

  static int calculateSlot(String? subLocation) {
    if (subLocation == null) return 0;
    try {
      final parts = subLocation.split('/');
      final last = parts.lastWhere(
        (p) => p.trim().isNotEmpty,
        orElse: () => '',
      );
      final parsed = int.tryParse(last);
      return parsed ?? 0;
    } catch (_) {
      return 0;
    }
  }

  // From Odoo data
  factory ProductModel.fromFirebaseData(Map<String, dynamic> data) {
    final actualStock = data['quantity'] ?? 0;

    return ProductModel(
      id: data['id'].toString(),
      name: data['name'] ?? 'Unknown Product',
      price: (data['price'] ?? 0.0).toDouble(),
      stock: actualStock,
      imageUrl:
          data['image_1920'] ??
          'https://images.unsplash.com/photo-1566478989037-eec170784d0b?w=400',
      slots: [],
      stockPerSlot: {},
      slot: 0,
      category: data['category'],
      categoryId: data['categoryId']?.toString(),
      slotType: data['slot_types'],
      mainwarehouseqty: 0,
      productTagIds: const [],
    );
  }

  // Default product
  factory ProductModel.defaultProduct({
    required String name,
    required double price,
    required int slot,
    CategoryModelApp? category,
  }) {
    return ProductModel(
      id: slot.toString(),
      name: name,
      price: price,
      stock: 15,
      imageUrl:
          'https://images.unsplash.com/photo-1566478989037-eec170784d0b?w=400',
      slots: [slot.toString().padLeft(2, '0')],
      stockPerSlot: {slot.toString().padLeft(2, '0'): 15},
      slot: slot,
      category: category,
      categoryId: category?.id,

      mainwarehouseqty: 0,
      productTagIds: const [],
      tags: const [],
    );
  }

  // Convert to Firebase map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'stock': totalStock,
      'imageUrl': imageUrl,
      'slots': slots,
      'stock_per_slot': stockPerSlot,
      'slot': slot,
      // 'category': category, // REMOVED: Only save categoryId
      'categoryId': categoryId,

      // NEW
      'is_merged': isMerged,
      'merged_slot_ids': mergedSlotIds,
      'slot_types': slotType,

      'mainwarehouseqty': mainwarehouseqty,
      'price_per_machine': pricePerMachine,
      'productTagIds': productTagIds,
      if (expiryDate != null) 'expiry_date': Timestamp.fromDate(expiryDate!),
      if (localFilePath != null) 'localFilePath': localFilePath,
      if (cachedImageUrl != null) 'cachedImageUrl': cachedImageUrl,
      'blocked_slots': blockedSlots,
    };
  }

  // From Firebase map
  factory ProductModel.fromMap(Map<String, dynamic> map, {String autoId = ''}) {
    List<String> slots = map['slots'] is List
        ? List<String>.from(map['slots'])
        : [];

    Map<String, int> stockPerSlot = {};
    if (map['stock_per_slot'] is Map) {
      stockPerSlot = (map['stock_per_slot'] as Map).map(
        (key, value) => MapEntry(key.toString(), value as int),
      );
    }

    return ProductModel(
      autoId: autoId,
      id: map['id']?.toString() ?? map['slot']?.toString() ?? '0',
      name: map['name'] ?? 'Unknown Product',
      price: (map['price'] ?? 0.0).toDouble(),
      stock: map['stock'] ?? 0,
      imageUrl:
          map['imageUrl'] ??
          map['image_url'] ??
          'https://images.unsplash.com/photo-1566478989037-eec170784d0b?w=400',
      slots: slots,
      stockPerSlot: stockPerSlot,
      slot: map['slot'] ?? 0,
      category: map['category'] != null && map.containsKey('category')
          ? CategoryModelApp.fromMap(map['category'])
          : null,
      categoryId:
          map['categoryId']?.toString() ??
          (map['category'] != null ? map['category']['id']?.toString() : null),

      // NEW
      isMerged: map['is_merged'] ?? false,
      cutPricePerMachine: (map['cut_price_per_machine'] as num?)?.toDouble(),
      descriptionPerMachine: map['description_per_machine'],
      mergedSlotIds: map['merged_slot_ids'] is List
          ? List<String>.from(map['merged_slot_ids'])
          : [],
      slotType: map['slot_types'] is Map
          ? (map['slot_types'] as Map).map(
              (key, value) => MapEntry(key.toString(), value as String),
            )
          : {},

      mainwarehouseqty: map['mainwarehouseqty'] ?? 0,
      pricePerMachine:
          map.containsKey('price_per_machine') &&
              map['price_per_machine'] != null
          ? (map['price_per_machine'] ?? 0.0).toDouble()
          : 0,
      productTagIds: map['productTagIds'] is List
          ? List<String>.from(map['productTagIds'])
          : [],
      tags: const [],
      expiryDate: map['expiry_date'] == null
          ? null
          : map['expiry_date'] is Timestamp
          ? (map['expiry_date'] as Timestamp).toDate()
          : map['expiry_date'] is String
          ? DateTime.tryParse(map['expiry_date'])
          : null,
      localFilePath: map['localFilePath'],
      cachedImageUrl: map['cachedImageUrl'],
      blockedSlots: map['blocked_slots'] is List
          ? List<String>.from(map['blocked_slots'])
          : [],
    );
  }

  ProductModel copyWith({
    String? id,
    String? name,
    double? price,
    int? stock,
    String? imageUrl,
    List<String>? slots,
    Map<String, int>? stockPerSlot,
    int? slot,
    CategoryModelApp? category,
    bool? isMerged,
    List<String>? mergedSlotIds,
    int? mainwarehouseqty,
    double? pricePerMachine,
    String? categoryId,
    List<String>? productTagIds,
    List<ProductTagModel>? tags,
    String? descriptionPerMachine,
    double? cutPricePerMachine,
    DateTime? expiryDate,
    String? localFilePath,
    String? cachedImageUrl,
    List<String>? blockedSlots,
    Map<String, String>? slotType,
  }) {
    return ProductModel(
      autoId: autoId ?? this.autoId,
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      imageUrl: imageUrl ?? this.imageUrl,
      slots: slots ?? this.slots,
      stockPerSlot: stockPerSlot ?? this.stockPerSlot,
      slot: slot ?? this.slot,
      category: category ?? this.category,
      categoryId: categoryId ?? this.categoryId,
      slotType: slotType ?? this.slotType,

      // NEW
      isMerged: isMerged ?? this.isMerged,
      mergedSlotIds: mergedSlotIds ?? this.mergedSlotIds,

      mainwarehouseqty: mainwarehouseqty ?? this.mainwarehouseqty,
      pricePerMachine: pricePerMachine ?? this.pricePerMachine,
      productTagIds: productTagIds ?? this.productTagIds,
      tags: tags ?? this.tags,
      descriptionPerMachine:
          descriptionPerMachine ?? this.descriptionPerMachine,
      cutPricePerMachine: cutPricePerMachine ?? this.cutPricePerMachine,
      expiryDate: expiryDate ?? this.expiryDate,
      localFilePath: localFilePath ?? this.localFilePath,
      cachedImageUrl: cachedImageUrl ?? this.cachedImageUrl,
      blockedSlots: blockedSlots ?? this.blockedSlots,
    );
  }
}
