import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:user/models/machine_model.dart';
import 'package:user/providers/machine_map_provider.dart';
import 'package:user/theme/apptheme.dart';
import 'package:hugeicons/hugeicons.dart';
import 'dart:developer' as dev;

class MachineMapScreen extends StatefulWidget {
  const MachineMapScreen({super.key});

  @override
  State<MachineMapScreen> createState() => _MachineMapScreenState();
}

class _MachineMapScreenState extends State<MachineMapScreen>
    with SingleTickerProviderStateMixin {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  LatLng? _initialPosition;
  bool _mapCreated = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<MachineMapProvider>();
      await provider.fetchMachines();
      await provider.getCurrentLocation();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _updateMarkers(List<MachineModel> machines) {
    final newMarkers = <Marker>{};

    for (final machine in machines) {
      if (machine.latitude != null && machine.longitude != null) {
        final position = LatLng(machine.latitude!, machine.longitude!);
        newMarkers.add(
          Marker(
            markerId: MarkerId(machine.machineId),
            position: position,
            infoWindow: InfoWindow(
              title: machine.username,
              snippet: machine.location ?? 'No address',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueViolet,
            ),
            onTap: () {
              dev.log("Clicked Machine ID: ${machine.machineId}");
            },
          ),
        );
      }
    }

    if (_markers.length != newMarkers.length ||
        !_markers.every(
          (m) => newMarkers.any((nm) => nm.markerId == m.markerId),
        )) {
      setState(() {
        _markers = newMarkers;
      });
    }

    if (!_mapCreated && machines.isNotEmpty && _initialPosition == null) {
      final firstMachineWithLocation = machines.firstWhere(
        (m) => m.latitude != null && m.longitude != null,
        orElse: () => machines.first,
      );

      if (firstMachineWithLocation.latitude != null &&
          firstMachineWithLocation.longitude != null) {
        _initialPosition = LatLng(
          firstMachineWithLocation.latitude!,
          firstMachineWithLocation.longitude!,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Apptheme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Consumer<MachineMapProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return _buildLoadingState(theme);
          }

          if (provider.errorMessage != null) {
            return _buildErrorState(theme, provider);
          }

          final machinesWithLocation = provider.machinesWithLocation;

          if (machinesWithLocation.isEmpty) {
            return _buildEmptyState(theme);
          }

          WidgetsBinding.instance.addPostFrameCallback((_) {
            _updateMarkers(machinesWithLocation);
          });

          return Stack(
            children: [
              // Google Map
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: provider.userPosition != null
                      ? LatLng(
                          provider.userPosition!.latitude,
                          provider.userPosition!.longitude,
                        )
                      : (_initialPosition ??
                            LatLng(
                              machinesWithLocation.first.latitude!,
                              machinesWithLocation.first.longitude!,
                            )),
                  zoom: 13,
                ),
                onMapCreated: (controller) {
                  _mapController = controller;
                  _mapCreated = true;
                },
                markers: _markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                padding: EdgeInsets.only(bottom: size.height * 0.35),
              ),

              // Custom App Bar
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _CustomMapAppBar(
                  theme: theme,
                  count: machinesWithLocation.length,
                ),
              ),

              // My Location Button
              Positioned(
                bottom: size.height * 0.38,
                right: 16,
                child: _MapFloatingButton(
                  icon: HugeIcons.strokeRoundedGps01,
                  onTap: () {
                    if (provider.userPosition != null) {
                      _mapController?.animateCamera(
                        CameraUpdate.newLatLng(
                          LatLng(
                            provider.userPosition!.latitude,
                            provider.userPosition!.longitude,
                          ),
                        ),
                      );
                    } else {
                      provider.getCurrentLocation();
                    }
                  },
                  theme: theme,
                ),
              ),

              // Zoom Controls
              Positioned(
                bottom: size.height * 0.48,
                right: 16,
                child: Column(
                  children: [
                    _MapFloatingButton(
                      icon: HugeIcons.strokeRoundedPlusSign,
                      onTap: () {
                        _mapController?.animateCamera(CameraUpdate.zoomIn());
                      },
                      theme: theme,
                    ),
                    const SizedBox(height: 8),
                    _MapFloatingButton(
                      icon: HugeIcons.strokeRoundedMinusSign,
                      onTap: () {
                        _mapController?.animateCamera(CameraUpdate.zoomOut());
                      },
                      theme: theme,
                    ),
                  ],
                ),
              ),

              // Machine Count Card
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoadingState(dynamic theme) {
    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [theme.primary.withOpacity(0.1), theme.primaryBackground],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: theme.primary.withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: CircularProgressIndicator(
                  color: theme.primary,
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Loading Machines...',
                style: TextStyle(
                  color: theme.primaryText,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please wait while we fetch nearby machines',
                style: TextStyle(color: theme.secondaryText, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(dynamic theme, MachineMapProvider provider) {
    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 56,
                  color: Colors.red[300],
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Unable to Load Map',
                style: TextStyle(
                  color: theme.primaryText,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                provider.errorMessage!,
                style: TextStyle(color: theme.secondaryText, fontSize: 15),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Go Back'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.primary,
                      side: BorderSide(color: theme.primary.withOpacity(0.3)),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () => provider.fetchMachines(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(dynamic theme) {
    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: theme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedLocation01,
                  color: theme.primary,
                  size: 56,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'No Machines Found',
                style: TextStyle(
                  color: theme.primaryText,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'There are no vending machines with location data available at the moment',
                style: TextStyle(color: theme.secondaryText, fontSize: 15),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Go Back'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomMapAppBar extends StatelessWidget {
  final dynamic theme;
  final int count;

  const _CustomMapAppBar({required this.theme, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 16,
        right: 16,
        bottom: 16,
      ),
      decoration: BoxDecoration(color: Colors.white),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                color: theme.primary,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Find Machines',
                  style: TextStyle(
                    color: Color(0xFF1F2937),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Discover vending machines near you',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          ),

          _MachineCountCard(count: count, theme: theme),
        ],
      ),
    );
  }
}

class _MapFloatingButton extends StatelessWidget {
  final dynamic icon;
  final VoidCallback onTap;
  final dynamic theme;

  const _MapFloatingButton({
    required this.icon,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: HugeIcon(icon: icon, color: theme.primary, size: 22),
      ),
    );
  }
}

class _MachineCountCard extends StatelessWidget {
  final int count;
  final dynamic theme;

  const _MachineCountCard({required this.count, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedSmartPhone01,
              color: theme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$count',
                style: TextStyle(
                  color: theme.primaryText,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Machines found',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
