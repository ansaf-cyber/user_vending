import 'dart:async';
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

      // Use last known position immediately for a snappy first render
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) {
        _userPosition = lastKnown;
        notifyListeners();
      }

      // Use a position stream to get the first available fix.
      // This avoids the GPS cold-start timeout that plagues getCurrentPosition.
      try {
        const locationSettings = LocationSettings(
          accuracy: LocationAccuracy.medium,
        );

        final position =
            await Geolocator.getPositionStream(
              locationSettings: locationSettings,
            ).first.timeout(
              const Duration(seconds: 30),
              onTimeout: () {
                // If stream times out, retain last known if we have it
                if (_userPosition == null) {
                  log('Location stream timed out with no position.');
                }
                throw TimeoutException('Location stream timed out');
              },
            );

        _userPosition = position;
        notifyListeners();
        log('Location acquired: ${position.latitude}, ${position.longitude}');
      } on TimeoutException {
        log('Location timed out. Using last known position if available.');
      }
    } catch (e) {
      log('Error getting location: $e');
    }
  }
}
