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

  Future<void> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _errorMessage = 'Location services are disabled.';
      notifyListeners();
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _errorMessage = 'Location permissions are denied';
        notifyListeners();
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _errorMessage = 'Location permissions are permanently denied';
      notifyListeners();
      return;
    }

    try {
      _userPosition = await Geolocator.getCurrentPosition();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error getting location: $e';
      notifyListeners();
    }
  }
}
