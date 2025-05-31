import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_accident_system/models/accident_model.dart';
import 'package:road_accident_system/providers/accident_provider.dart';
import 'package:intl/intl.dart';

class MapAccidentsLocationScreen extends ConsumerStatefulWidget {
  const MapAccidentsLocationScreen({super.key});

  @override
  ConsumerState<MapAccidentsLocationScreen> createState() =>
      _MapAccidentsLocationScreenState();
}

class _MapAccidentsLocationScreenState
    extends ConsumerState<MapAccidentsLocationScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  bool _showFilters = false;
  String? _selectedSeverity;
  String? _selectedType;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    final accidentSync = ref.watch(streamAccidentProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accident Locations'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters section
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _showFilters ? 120 : 0,
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Filter Accidents',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildFilterDropdown(
                            'Severity',
                            _selectedSeverity ?? 'All',
                            [
                              'All',
                              'Fatal',
                              'Serious Injury',
                              'Minor Injury',
                              'Property Damage',
                            ],
                            (value) {
                              setState(() {
                                _selectedSeverity =
                                    value != 'All' ? value : null;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildFilterDropdown(
                            'Type',
                            _selectedType ?? 'All',
                            [
                              'All',
                              'Vehicle-Vehicle',
                              'Vehicle-Pedestrian',
                              'Single Vehicle',
                              'Multiple Vehicle',
                            ],
                            (value) {
                              setState(() {
                                _selectedType = value != 'All' ? value : null;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: _clearFilters,
                          child: const Text('Clear Filters'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Map section
          Expanded(
            child: accidentSync.when(
              data: (accidents) {
                final filteredAccidents = _filterAccidents(accidents);
                _updateMarkers(filteredAccidents);

                return Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: const CameraPosition(
                        target: LatLng(-6.7924, 39.2083), // Dar es Salaam
                        zoom: 10,
                      ),
                      markers: _markers,
                      onMapCreated: (controller) {
                        _mapController = controller;
                        if (filteredAccidents.isNotEmpty) {
                          _mapController?.animateCamera(
                            CameraUpdate.newLatLngBounds(
                              _calculateBounds(filteredAccidents),
                              50,
                            ),
                          );
                        }
                      },
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                      mapToolbarEnabled: false,
                    ),

                    // Map controls
                    Positioned(
                      right: 16,
                      bottom: 100,
                      child: Column(
                        children: [
                          _buildMapControlButton(
                            Icons.add,
                            () => _mapController?.animateCamera(
                              CameraUpdate.zoomIn(),
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildMapControlButton(
                            Icons.remove,
                            () => _mapController?.animateCamera(
                              CameraUpdate.zoomOut(),
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildMapControlButton(
                            Icons.my_location,
                            _centerOnUserLocation,
                          ),
                        ],
                      ),
                    ),

                    // Legend
                    Positioned(
                      left: 16,
                      bottom: 16,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Accident Severity',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildLegendItem('Fatal', Colors.red[700]!),
                            _buildLegendItem(
                              'Serious Injury',
                              Colors.orange[700]!,
                            ),
                            _buildLegendItem(
                              'Minor Injury',
                              Colors.yellow[700]!,
                            ),
                            _buildLegendItem(
                              'Property Damage',
                              Colors.blue[700]!,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Stats card
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Showing ${filteredAccidents.length} accidents',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            if (_selectedSeverity != null ||
                                _selectedType != null)
                              Text(
                                'Filters applied',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(
    String label,
    String value,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            icon: const Icon(Icons.arrow_drop_down),
            style: TextStyle(color: Colors.grey[800], fontSize: 14),
            onChanged: (String? newValue) {
              onChanged(newValue);
            },
            items:
                items.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMapControlButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon),
        onPressed: onPressed,
        color: Theme.of(context).primaryColor,
        iconSize: 20,
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 10)),
        ],
      ),
    );
  }

  void _updateMarkers(List<Accident> accidents) {
    setState(() {
      _markers =
          accidents.asMap().entries.expand((entry) {
            final index = entry.key;
            final accident = entry.value;

            // Create main marker
            final markers = <Marker>[
              Marker(
                markerId: MarkerId('accident_$index'),
                position: accident.location,
                infoWindow: InfoWindow(
                  title: accident.roadName,
                  snippet:
                      '${accident.type} - ${DateFormat('MMM dd, yyyy').format(accident.date)}',
                ),
                onTap: () {
                  _showAccidentDetailsModal(accident);
                },
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  _getSeverityHue(accident.effects),
                ),
              ),
            ];

            // Add additional points if any
            markers.addAll(
              accident.additionalPoints.asMap().entries.map(
                (point) => Marker(
                  markerId: MarkerId('accident_${index}_point_${point.key}'),
                  position: point.value,
                  infoWindow: InfoWindow(
                    title: 'Additional Point ${point.key + 1}',
                  ),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueBlue,
                  ),
                ),
              ),
            );

            return markers;
          }).toSet();
    });
  }

  void _showAccidentDetailsModal(Accident accident) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.4,
            minChildSize: 0.3,
            maxChildSize: 0.8,
            expand: false,
            builder: (context, scrollController) {
              return SingleChildScrollView(
                controller: scrollController,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _getSeverityColor(
                                accident.effects,
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              _getAccidentTypeIcon(accident.type),
                              color: _getSeverityColor(accident.effects),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  accident.type,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  accident.effects,
                                  style: TextStyle(
                                    color: _getSeverityColor(accident.effects),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),
                      _buildDetailItem(
                        'Date & Time',
                        DateFormat(
                          'MMM dd, yyyy - HH:mm',
                        ).format(accident.date),
                      ),
                      _buildDetailItem('Location', accident.roadName),
                      _buildDetailItem('Area', accident.area),
                      _buildDetailItem('Region', accident.region),
                      _buildDetailItem('Weather', accident.weather),
                      _buildDetailItem(
                        'Road Condition',
                        accident.environmentalFactors,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            // Navigate to detailed report screen
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('View Full Report'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  List<Accident> _filterAccidents(List<Accident> accidents) {
    return accidents.where((accident) {
      // Filter by severity
      if (_selectedSeverity != null && accident.effects != _selectedSeverity) {
        return false;
      }

      // Filter by type
      if (_selectedType != null && accident.type != _selectedType) {
        return false;
      }

      // Filter by date range
      if (_startDate != null && accident.date.isBefore(_startDate!)) {
        return false;
      }

      if (_endDate != null) {
        final endOfDay = DateTime(
          _endDate!.year,
          _endDate!.month,
          _endDate!.day,
          23,
          59,
          59,
        );
        if (accident.date.isAfter(endOfDay)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  void _clearFilters() {
    setState(() {
      _selectedSeverity = null;
      _selectedType = null;
      _startDate = null;
      _endDate = null;
    });
  }

  void _centerOnUserLocation() {
    // In a real app, you would get the user's location and center the map on it
    // For this example, we'll just center on a default location
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        const CameraPosition(target: LatLng(-6.7924, 39.2083), zoom: 12),
      ),
    );
  }

  LatLngBounds _calculateBounds(List<Accident> accidents) {
    if (accidents.isEmpty) {
      // Default bounds for Dar es Salaam
      return LatLngBounds(
        southwest: const LatLng(-7.0, 39.0),
        northeast: const LatLng(-6.5, 39.5),
      );
    }

    double minLat = 90.0;
    double maxLat = -90.0;
    double minLng = 180.0;
    double maxLng = -180.0;

    for (final accident in accidents) {
      final lat = accident.location.latitude;
      final lng = accident.location.longitude;

      minLat = lat < minLat ? lat : minLat;
      maxLat = lat > maxLat ? lat : maxLat;
      minLng = lng < minLng ? lng : minLng;
      maxLng = lng > maxLng ? lng : maxLng;

      // Also check additional points
      for (final point in accident.additionalPoints) {
        final pointLat = point.latitude;
        final pointLng = point.longitude;

        minLat = pointLat < minLat ? pointLat : minLat;
        maxLat = pointLat > maxLat ? pointLat : maxLat;
        minLng = pointLng < minLng ? pointLng : minLng;
        maxLng = pointLng > maxLng ? pointLng : maxLng;
      }
    }

    // Add some padding
    minLat -= 0.05;
    maxLat += 0.05;
    minLng -= 0.05;
    maxLng += 0.05;

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'Fatal':
        return Colors.red[700]!;
      case 'Serious Injury':
        return Colors.orange[700]!;
      case 'Minor Injury':
        return Colors.yellow[700]!;
      case 'Property Damage':
        return Colors.blue[700]!;
      default:
        return Colors.grey[700]!;
    }
  }

  double _getSeverityHue(String severity) {
    switch (severity) {
      case 'Fatal':
        return BitmapDescriptor.hueRed;
      case 'Serious Injury':
        return BitmapDescriptor.hueOrange;
      case 'Minor Injury':
        return BitmapDescriptor.hueYellow;
      case 'Property Damage':
        return BitmapDescriptor.hueBlue;
      default:
        return BitmapDescriptor.hueViolet;
    }
  }

  IconData _getAccidentTypeIcon(String type) {
    switch (type) {
      case 'Vehicle-Vehicle':
        return Icons.car_crash;
      case 'Vehicle-Pedestrian':
        return Icons.directions_walk;
      case 'Vehicle-Motorcycle':
        return Icons.motorcycle;
      case 'Single Vehicle':
        return Icons.directions_car;
      case 'Multiple Vehicle':
        return Icons.commute;
      default:
        return Icons.warning;
    }
  }
}
