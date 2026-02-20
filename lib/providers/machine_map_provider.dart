import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:user/models/machine_model.dart';
import 'package:geolocator/geolocator.dart';

class MachineMapProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<MachineModel> _machines = [];
  bool _isLoading = false;
  String? _errorMessage;
  Position? _userPosition;

  List<MachineModel> get machines => _machines;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Position? get userPosition => _userPosition;

  List<MachineModel> get machinesWithLocation => _machines
      .where((m) => m.latitude != null && m.longitude != null)
      .toList();

  Future<void> fetchMachines() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final snapshot = await _firestore.collection('machines').get();

      log("snapshot.docs.length.toString() ${snapshot.docs.length}");

      _machines = snapshot.docs.map((doc) {
        final data = doc.data();
        data['machine_id'] = doc.id;
        return MachineModel.fromJson(data);
      }).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      log(e.toString());
      _errorMessage = 'Failed to fetch machines: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMachinesByOwner(String ownerId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('machines')
          .where('isActive', isEqualTo: true)
          .where('ownerId', isEqualTo: ownerId)
          .get();

      _machines = snapshot.docs.map((doc) {
        final data = doc.data();
        data['machine_id'] = doc.id;
        return MachineModel.fromJson(data);
      }).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to fetch machines: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> initializedata() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Parallel fetch machines and try to get location
      await Future.wait([fetchMachines(), getCurrentLocation()]);
    } catch (e) {
      log("Error during initialization: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        log('Location services are disabled.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          log('Location permissions are denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        log('Location permissions are permanently denied');
        return;
      }

      _userPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 5),
      );
      notifyListeners();
    } catch (e) {
      log('Error getting location: $e');
      // We don't set global _errorMessage here to avoid blocking the map if only location fails
    }
  }
}
