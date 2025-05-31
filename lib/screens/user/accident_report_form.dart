import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:road_accident_system/models/accident_model.dart';
import 'package:road_accident_system/providers/accident_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:io';

class AccidentReportForm extends ConsumerStatefulWidget {
  const AccidentReportForm({super.key});

  @override
  ConsumerState<AccidentReportForm> createState() => _AccidentReportFormState();
}

class _AccidentReportFormState extends ConsumerState<AccidentReportForm> {
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();
  final List<File> _selectedImages = [];
  final List<LatLng> _additionalPoints = [];
  LatLng? _mainLocation;
  bool _isLoading = false;

  // Form controllers
  final _roadNameController = TextEditingController();
  final _areaController = TextEditingController();
  final _districtController = TextEditingController();
  final _regionController = TextEditingController();
  final _wardController = TextEditingController();
  String _selectedType = '';
  String _selectedEffects = '';
  String _selectedWeather = '';
  String _selectedVisibility = '';
  String _selectedPhysiologicalIssues = '';
  String _selectedEnvironmentalFactors = '';
  final List<InvolvedParty> _involvedParties = [];

  // Predefined options
  final List<String> _accidentTypes = [
    'Head-on Collision',
    'Rear-end Collision',
    'Side Impact',
    'Rollover',
    'Single Vehicle',
    'Pedestrian Accident',
    'Other',
  ];

  final List<String> _effects = [
    'Fatal',
    'Serious Injury',
    'Minor Injury',
    'Property Damage Only',
    'No Damage',
  ];

  final List<String> _weatherConditions = [
    'Clear',
    'Rainy',
    'Foggy',
    'Cloudy',
    'Stormy',
    'Other',
  ];

  final List<String> _visibilityConditions = [
    'Good',
    'Fair',
    'Poor',
    'Very Poor',
  ];

  final List<String> _physiologicalIssues = [
    'None',
    'Fatigue',
    'Alcohol',
    'Drugs',
    'Medical Condition',
    'Other',
  ];

  final List<String> _environmentalFactors = [
    'None',
    'Poor Road Condition',
    'Poor Lighting',
    'Road Construction',
    'Traffic Signal Issue',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        setState(() {
          _mainLocation = LatLng(position.latitude, position.longitude);
          _roadNameController.text = place.thoroughfare ?? '';
          _areaController.text = place.subLocality ?? '';
          _districtController.text = place.subAdministrativeArea ?? '';
          _regionController.text = place.administrativeArea ?? '';
          _wardController.text = place.locality ?? '';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error getting location: $e')));
    }
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images.map((image) => File(image.path)));
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${images.length} photos added successfully'),
            backgroundColor: Colors.green[700],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting photos: $e'),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  void _addInvolvedParty() {
    final typeController = TextEditingController();
    final detailsController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final primaryColor = Theme.of(context).primaryColor;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.person_add, color: primaryColor, size: 24),
              SizedBox(width: 8),
              Text(
                'Add Involved Party',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: typeController,
                  decoration: InputDecoration(
                    labelText: 'Type *',
                    hintText: 'e.g., Vehicle, Pedestrian, Cyclist',
                    prefixIcon: Icon(Icons.category, color: primaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator:
                      (value) =>
                          value?.isEmpty ?? true ? 'Type is required' : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: detailsController,
                  decoration: InputDecoration(
                    labelText: 'Details *',
                    hintText: 'e.g., Vehicle Plate, Person Name',
                    prefixIcon: Icon(Icons.description, color: primaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator:
                      (value) =>
                          value?.isEmpty ?? true
                              ? 'Details are required'
                              : null,
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'CANCEL',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  setState(() {
                    _involvedParties.add(
                      InvolvedParty(
                        type: typeController.text,
                        details: detailsController.text,
                      ),
                    );
                  });
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
              ),
              child: Text('ADD'),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        );
      },
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() || _mainLocation == null) {
      // Show validation error with more details
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text('Please fill all required fields marked with *'),
              ),
            ],
          ),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final accident = Accident(
        roadName: _roadNameController.text,
        area: _areaController.text,
        district: _districtController.text,
        region: _regionController.text,
        ward: _wardController.text,
        date: DateTime.now(),
        type: _selectedType,
        effects: _selectedEffects,
        visibility: _selectedVisibility,
        weather: _selectedWeather,
        physiologicalIssues: _selectedPhysiologicalIssues,
        environmentalFactors: _selectedEnvironmentalFactors,
        location: _mainLocation!,
        additionalPoints: _additionalPoints,
        photoUrls: [], // Will be updated after upload
        involvedParties: _involvedParties,
        createdAt: DateTime.now(),
      );

      await ref.read(accidentServiceProvider).createAccident(accident);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Expanded(child: Text('Accident report submitted successfully')),
            ],
          ),
          backgroundColor: Colors.green[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: Duration(seconds: 3),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 8),
              Expanded(child: Text('Error submitting report: $e')),
            ],
          ),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: Duration(seconds: 5),
          action: SnackBarAction(
            label: 'RETRY',
            textColor: Colors.white,
            onPressed: _submitForm,
          ),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: Text('Register Accident'),
        foregroundColor: Colors.white,
        backgroundColor: primaryColor,
        elevation: 2,
        actions: [
          if (_isLoading)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Status bar
              Container(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                color: Colors.grey[100],
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 18, color: primaryColor),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'All fields marked with * are mandatory. Please provide accurate information.',
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                    ),
                  ],
                ),
              ),

              // Form content
              Expanded(
                child: ListView(
                  padding: EdgeInsets.all(16),
                  children: [
                    // Official header
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: primaryColor.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.shield,
                                  color: primaryColor,
                                  size: 24,
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'OFFICIAL ACCIDENT REPORT',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: primaryColor,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Ministry of Transportation',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Report ID: ${DateTime.now().millisecondsSinceEpoch.toString().substring(0, 10)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                          Text(
                            'Date: ${DateTime.now().toString().substring(0, 16)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 24),

                    // Location Information Section
                    _buildSectionHeader(
                      context,
                      'Location Information',
                      Icons.location_on,
                    ),
                    SizedBox(height: 16),

                    Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_mainLocation != null)
                              Container(
                                height: 120,
                                margin: EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Stack(
                                    children: [
                                      GoogleMap(
                                        initialCameraPosition: CameraPosition(
                                          target: _mainLocation!,
                                          zoom: 15,
                                        ),
                                        markers: {
                                          Marker(
                                            markerId: MarkerId(
                                              'accident_location',
                                            ),
                                            position: _mainLocation!,
                                          ),
                                        },
                                        zoomControlsEnabled: false,
                                        mapToolbarEnabled: false,
                                        myLocationButtonEnabled: false,
                                      ),
                                      Positioned(
                                        right: 8,
                                        bottom: 8,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                  0.1,
                                                ),
                                                blurRadius: 2,
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.my_location,
                                                size: 12,
                                                color: primaryColor,
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                'Current Location',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.grey[800],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              Container(
                                height: 120,
                                margin: EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              primaryColor,
                                            ),
                                        strokeWidth: 2,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Getting location...',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                            _buildFormField(
                              controller: _roadNameController,
                              labelText: 'Road Name *',
                              prefixIcon: Icons.route,
                              validator:
                                  (value) =>
                                      value?.isEmpty ?? true
                                          ? 'Required'
                                          : null,
                            ),
                            SizedBox(height: 16),

                            Row(
                              children: [
                                Expanded(
                                  child: _buildFormField(
                                    controller: _areaController,
                                    labelText: 'Area *',
                                    prefixIcon: Icons.location_city,
                                    validator:
                                        (value) =>
                                            value?.isEmpty ?? true
                                                ? 'Required'
                                                : null,
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: _buildFormField(
                                    controller: _districtController,
                                    labelText: 'District *',
                                    prefixIcon: Icons.map,
                                    validator:
                                        (value) =>
                                            value?.isEmpty ?? true
                                                ? 'Required'
                                                : null,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),

                            Row(
                              children: [
                                Expanded(
                                  child: _buildFormField(
                                    controller: _regionController,
                                    labelText: 'Region *',
                                    prefixIcon: Icons.public,
                                    validator:
                                        (value) =>
                                            value?.isEmpty ?? true
                                                ? 'Required'
                                                : null,
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: _buildFormField(
                                    controller: _wardController,
                                    labelText: 'Ward *',
                                    prefixIcon: Icons.location_on,
                                    validator:
                                        (value) =>
                                            value?.isEmpty ?? true
                                                ? 'Required'
                                                : null,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 24),

                    // Accident Details Section
                    _buildSectionHeader(
                      context,
                      'Accident Details',
                      Icons.warning_amber,
                    ),
                    SizedBox(height: 16),

                    Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDropdownField(
                              labelText: 'Accident Type *',
                              prefixIcon: Icons.warning,
                              value:
                                  _selectedType.isEmpty ? null : _selectedType,
                              items:
                                  _accidentTypes.map((type) {
                                    return DropdownMenuItem(
                                      value: type,
                                      child: Text(type),
                                    );
                                  }).toList(),
                              onChanged: (value) {
                                setState(() => _selectedType = value ?? '');
                              },
                              validator:
                                  (value) =>
                                      value?.isEmpty ?? true
                                          ? 'Required'
                                          : null,
                            ),
                            SizedBox(height: 16),

                            _buildDropdownField(
                              labelText: 'Effects *',
                              prefixIcon: Icons.medical_services,
                              value:
                                  _selectedEffects.isEmpty
                                      ? null
                                      : _selectedEffects,
                              items:
                                  _effects.map((effect) {
                                    return DropdownMenuItem(
                                      value: effect,
                                      child: Text(effect),
                                    );
                                  }).toList(),
                              onChanged: (value) {
                                setState(() => _selectedEffects = value ?? '');
                              },
                              validator:
                                  (value) =>
                                      value?.isEmpty ?? true
                                          ? 'Required'
                                          : null,
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 24),

                    // Environmental Conditions Section
                    _buildSectionHeader(
                      context,
                      'Environmental Conditions',
                      Icons.cloud,
                    ),
                    SizedBox(height: 16),

                    Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDropdownField(
                              labelText: 'Weather *',
                              prefixIcon: Icons.cloud,
                              value:
                                  _selectedWeather.isEmpty
                                      ? null
                                      : _selectedWeather,
                              items:
                                  _weatherConditions.map((weather) {
                                    return DropdownMenuItem(
                                      value: weather,
                                      child: Text(weather),
                                    );
                                  }).toList(),
                              onChanged: (value) {
                                setState(() => _selectedWeather = value ?? '');
                              },
                              validator:
                                  (value) =>
                                      value?.isEmpty ?? true
                                          ? 'Required'
                                          : null,
                            ),
                            SizedBox(height: 16),

                            _buildDropdownField(
                              labelText: 'Visibility *',
                              prefixIcon: Icons.visibility,
                              value:
                                  _selectedVisibility.isEmpty
                                      ? null
                                      : _selectedVisibility,
                              items:
                                  _visibilityConditions.map((visibility) {
                                    return DropdownMenuItem(
                                      value: visibility,
                                      child: Text(visibility),
                                    );
                                  }).toList(),
                              onChanged: (value) {
                                setState(
                                  () => _selectedVisibility = value ?? '',
                                );
                              },
                              validator:
                                  (value) =>
                                      value?.isEmpty ?? true
                                          ? 'Required'
                                          : null,
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 24),

                    // Additional Factors Section
                    _buildSectionHeader(
                      context,
                      'Additional Factors',
                      Icons.fact_check,
                    ),
                    SizedBox(height: 16),

                    Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDropdownField(
                              labelText: 'Physiological Issues',
                              prefixIcon: Icons.person,
                              value:
                                  _selectedPhysiologicalIssues.isEmpty
                                      ? null
                                      : _selectedPhysiologicalIssues,
                              items:
                                  _physiologicalIssues.map((issue) {
                                    return DropdownMenuItem(
                                      value: issue,
                                      child: Text(issue),
                                    );
                                  }).toList(),
                              onChanged: (value) {
                                setState(
                                  () =>
                                      _selectedPhysiologicalIssues =
                                          value ?? '',
                                );
                              },
                            ),
                            SizedBox(height: 16),

                            _buildDropdownField(
                              labelText: 'Environmental Factors',
                              prefixIcon: Icons.landscape,
                              value:
                                  _selectedEnvironmentalFactors.isEmpty
                                      ? null
                                      : _selectedEnvironmentalFactors,
                              items:
                                  _environmentalFactors.map((factor) {
                                    return DropdownMenuItem(
                                      value: factor,
                                      child: Text(factor),
                                    );
                                  }).toList(),
                              onChanged: (value) {
                                setState(
                                  () =>
                                      _selectedEnvironmentalFactors =
                                          value ?? '',
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 24),

                    // Involved Parties Section
                    _buildSectionHeader(
                      context,
                      'Involved Parties',
                      Icons.people,
                      trailing: IconButton(
                        icon: Icon(Icons.add_circle, color: primaryColor),
                        onPressed: _addInvolvedParty,
                        tooltip: 'Add Involved Party',
                      ),
                    ),
                    SizedBox(height: 16),

                    Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_involvedParties.isEmpty)
                              Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.people_outline,
                                        size: 48,
                                        color: Colors.grey[400],
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'No parties added yet',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Tap + to add involved parties',
                                        style: TextStyle(
                                          color: Colors.grey[500],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              ListView.separated(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: _involvedParties.length,
                                separatorBuilder:
                                    (context, index) => Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final party = _involvedParties[index];
                                  return ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: primaryColor.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Icon(
                                          party.type.toLowerCase().contains(
                                                'vehicle',
                                              )
                                              ? Icons.directions_car
                                              : Icons.person,
                                          color: primaryColor,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      party.type,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                    ),
                                    subtitle: Text(
                                      party.details,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    trailing: IconButton(
                                      icon: Icon(
                                        Icons.delete_outline,
                                        color: Colors.red[400],
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _involvedParties.removeAt(index);
                                        });
                                      },
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 24),

                    // Photos Section
                    _buildSectionHeader(
                      context,
                      'Evidence Photos',
                      Icons.photo_camera,
                    ),
                    SizedBox(height: 16),

                    Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_selectedImages.isNotEmpty)
                              Container(
                                height: 100,
                                margin: EdgeInsets.only(bottom: 16),
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _selectedImages.length,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      width: 100,
                                      margin: EdgeInsets.only(right: 8),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.grey[300]!,
                                        ),
                                      ),
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: Image.file(
                                              _selectedImages[index],
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          Positioned(
                                            right: 0,
                                            top: 0,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.black.withOpacity(
                                                  0.5,
                                                ),
                                                borderRadius: BorderRadius.only(
                                                  bottomLeft: Radius.circular(
                                                    8,
                                                  ),
                                                  topRight: Radius.circular(8),
                                                ),
                                              ),
                                              child: IconButton(
                                                icon: Icon(
                                                  Icons.close,
                                                  color: Colors.white,
                                                  size: 16,
                                                ),
                                                padding: EdgeInsets.all(4),
                                                constraints: BoxConstraints(),
                                                onPressed: () {
                                                  setState(() {
                                                    _selectedImages.removeAt(
                                                      index,
                                                    );
                                                  });
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              )
                            else
                              Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.photo_library_outlined,
                                        size: 48,
                                        color: Colors.grey[400],
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'No photos added yet',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                            SizedBox(height: 8),

                            ElevatedButton.icon(
                              onPressed: _pickImages,
                              icon: Icon(Icons.add_photo_alternate),
                              label: Text('Add Photos'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                minimumSize: Size(double.infinity, 48),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 32),

                    // Legal disclaimer
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'LEGAL DISCLAIMER',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'By submitting this report, I confirm that the information provided is accurate to the best of my knowledge. False reporting may lead to legal consequences under the Traffic Act.',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 24),

                    // Submit button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                      ),
                      child:
                          _isLoading
                              ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text('Submitting Report...'),
                                ],
                              )
                              : Text(
                                'SUBMIT OFFICIAL REPORT',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                    ),

                    SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _roadNameController.dispose();
    _areaController.dispose();
    _districtController.dispose();
    _regionController.dispose();
    _wardController.dispose();
    super.dispose();
  }
}

// Helper method to build section headers
Widget _buildSectionHeader(
  BuildContext context,
  String title,
  IconData icon, {
  Widget? trailing,
}) {
  final primaryColor = Theme.of(context).primaryColor;

  return Row(
    children: [
      Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: primaryColor, size: 18),
      ),
      SizedBox(width: 8),
      Expanded(
        child: Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
            letterSpacing: 0.5,
          ),
        ),
      ),
      if (trailing != null) trailing,
    ],
  );
}

// Helper method to build form fields
Widget _buildFormField({
  required TextEditingController controller,
  required String labelText,
  required IconData prefixIcon,
  String? Function(String?)? validator,
  TextInputType keyboardType = TextInputType.text,
}) {
  return TextFormField(
    controller: controller,
    validator: validator,
    keyboardType: keyboardType,
    decoration: InputDecoration(
      labelText: labelText,
      prefixIcon: Icon(prefixIcon, size: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.blue[700]!, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.red[400]!, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.red[400]!, width: 1.5),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    style: TextStyle(fontSize: 14),
  );
}

// Helper method to build dropdown fields
Widget _buildDropdownField<T>({
  required String labelText,
  required IconData prefixIcon,
  required T? value,
  required List<DropdownMenuItem<T>> items,
  required void Function(T?) onChanged,
  String? Function(T?)? validator,
}) {
  return DropdownButtonFormField<T>(
    value: value,
    items: items,
    onChanged: onChanged,
    validator: validator,
    decoration: InputDecoration(
      labelText: labelText,
      prefixIcon: Icon(prefixIcon, size: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.blue[700]!, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.red[400]!, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.red[400]!, width: 1.5),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    style: TextStyle(fontSize: 14),
    icon: Icon(Icons.arrow_drop_down, color: Colors.grey[700]),
    isExpanded: true,
    dropdownColor: Colors.white,
  );
}
