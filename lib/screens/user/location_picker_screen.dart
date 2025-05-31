import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationDetails {
  final LatLng position;
  final String region;
  final String district;
  final String ward;
  final String roadName;

  LocationDetails({
    required this.position,
    required this.region,
    required this.district,
    required this.ward,
    required this.roadName,
  });
}

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  State createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  LatLng? _pickedLocation;

  // void _onTap(LatLng position) {
  //   setState(() {
  //     _pickedLocation = position;
  //   });
  // }

  // LatLng? _pickedLocation;
  LocationDetails? _locationDetails;

  Future<void> _onTap(LatLng position) async {
    setState(() {
      _pickedLocation = position;
    });

    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final details = LocationDetails(
          position: position,
          region: place.administrativeArea ?? '',
          district: place.subAdministrativeArea ?? '',
          ward: place.locality ?? '',
          roadName: place.street ?? '',
        );

        setState(() {
          _locationDetails = details;
        });
      }
    } catch (e) {
      setState(() {});
    }
  }

  void _submitLocation() {
    if (_locationDetails != null) {
      Navigator.pop(context, _locationDetails);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pick Location')),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(-6.7924, 39.2083), // Dar es Salaam
          zoom: 14,
        ),
        onTap: _onTap,
        markers:
            _pickedLocation != null
                ? {
                  Marker(
                    markerId: MarkerId('selected'),
                    position: _pickedLocation!,
                  ),
                }
                : {},
      ),
      floatingActionButton:
          _pickedLocation != null
              ? FloatingActionButton(
                onPressed: _submitLocation,
                child: Icon(Icons.check),
              )
              : null,
    );
  }
}
