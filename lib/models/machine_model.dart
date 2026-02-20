import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

/// Model representing machine configuration data from Firebase
class MachineModel {
  // Machine Identity
  final String machineId;
  final String location;
  final String status; // online, offline
  final String? ownerId;
  final String? username;
  final String? manufacturer;
double? latitude;
double? longitude;
  // New Settings Fields
  final String currency; // KWD, USD, EUR, AED, SAR, etc.
  final int priceDecimal; // 2 or 3 decimal places
 
  // 1: smallest slot, 2: highest slot, 3: highest stock, 4: lowest stock

  // Payment Configuration

  final String? logoUrl;

  // Media Configuration

  // Operational Settings

  final Timestamp? lastSeen;
  final Timestamp? offlineDetectedAt;

  MachineModel({
    required this.machineId,
    required this.location,
    this.status = 'offline',
    required this.latitude,
    required this.longitude,
    this.ownerId,
    required this.username,
    this.manufacturer,
    this.currency = 'KWD',
    this.priceDecimal = 3,
   

    this.logoUrl,

    this.lastSeen,
    this.offlineDetectedAt,
  });

  /// Create MachineModel from Firebase document data
  factory MachineModel.fromJson(Map<String, dynamic> json) {
    // log("machine data ${json.toString()}");
    return MachineModel(
      latitude: _toDouble(json['latitude']) ?? 0,
      longitude: _toDouble(json['longitude']) ?? 0,
      machineId: json['machine_id'] ?? '',
      location: json['location'] ?? '',
      status: json['status'] ?? 'offline',
      ownerId: json['ownerId'],
      username: json['username'] ??json['machine_id'] ??'unknown',
      manufacturer: json['manufacturer'],
      currency: json['currency'] ?? 'KWD',
      priceDecimal: _validateDecimal(json['decimalViewOnly']),
      

      logoUrl: json['logoUrl'],

      lastSeen: _parseTimestamp(json['last_seen']),
      offlineDetectedAt: _parseTimestamp(json['offline_detected_at']),
    );
  }

  /// Safely convert dynamic value to double
  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// Parse timestamp from various formats (Timestamp, String, null)
  static Timestamp? _parseTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value;
    if (value is String) {
      try {
        return Timestamp.fromDate(DateTime.parse(value));
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Validate and clamp decimal precision to 2 or 3
  static int _validateDecimal(dynamic value) {
    if (value == null) return 3;
    final intValue = value is int ? value : int.tryParse(value.toString()) ?? 3;
    // Clamp to 2 or 3, default to 3 if out of range
    if (intValue == 2) return 2;
    return 3;
  }

  /// Convert MachineModel to JSON for Firebase
  Map<String, dynamic> toJson() {
    return {
      'machine_id': machineId,
      'location': location,
      'status': status,

      if (ownerId != null) 'ownerId': ownerId,

      if (manufacturer != null) 'manufacturer': manufacturer,
      'currency': currency,
      'priceDecimal': priceDecimal,

   

      if (logoUrl != null) 'logoUrl': logoUrl,

      if (lastSeen != null) 'last_seen': lastSeen,
      if (offlineDetectedAt != null) 'offline_detected_at': offlineDetectedAt,
    };
  }

  /// Create a copy of this model with updated fields
  MachineModel copyWith({
    String? machineId,
    String? location,
    String? status,
    String? ownerId,

    String? manufacturer,
    String? currency,
    int? priceDecimal,
    int? priceDecimalMdb,
    String? logoUrl,

    Timestamp? lastSeen,
    Timestamp? offlineDetectedAt,
    String? offlineReason,

    String? headerFooterTemplateId,
  }) {
    return MachineModel(
      username: username ?? this.username,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      machineId: machineId ?? this.machineId,
      location: location ?? this.location,
      status: status ?? this.status,
      ownerId: ownerId ?? this.ownerId,

      manufacturer: manufacturer ?? this.manufacturer,
      currency: currency ?? this.currency,
      priceDecimal: priceDecimal ?? this.priceDecimal,
    
      logoUrl: logoUrl ?? this.logoUrl,

     
      lastSeen: lastSeen ?? this.lastSeen,
      offlineDetectedAt: offlineDetectedAt ?? this.offlineDetectedAt,
    
      
     
    );
  }
}
