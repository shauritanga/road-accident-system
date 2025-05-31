import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:road_accident_system/screens/user/location_picker_screen.dart';

import 'package:image_picker/image_picker.dart';

final ImagePicker _picker = ImagePicker();

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  final _roadNameController = TextEditingController();
  final _areaController = TextEditingController();
  final _districtController = TextEditingController();
  final _regionController = TextEditingController();
  final _wardController = TextEditingController();
  final _effectsController = TextEditingController();
  final _visibilityController = TextEditingController();
  final _weatherController = TextEditingController();
  final _physiologyController = TextEditingController();
  final _environmentController = TextEditingController();

  // Dropdowns
  final List<String> _accidentTypes = [
    'Collision',
    'Overturning',
    'Pedestrian Involved',
    'Animal Involved',
    'Other',
  ];
  String? _accidentType;

  // Date & Time
  DateTime? _selectedDate;

  // Location
  LatLng? _pickedLocation;
  final List<LatLng> _additionalPoints = [];

  // Others
  final List<String> _photoUrls = [];
  final List<Map<String, String>> _involvedParties = [];

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickPhoto() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(
        () => _photoUrls.add(image.path),
      ); // Use image.path for local preview
    }
  }

  void _selectLocation() async {
    final LatLng? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LocationPickerScreen()),
    );
    if (result != null) {
      setState(() => _pickedLocation = result);
    }
  }

  void _addInvolvedParty() {
    setState(() {
      _involvedParties.add({'name': '', 'role': '', 'condition': ''});
    });
  }

  void _submitForm() {
    if (_formKey.currentState!.validate() && _pickedLocation != null) {
      // Collect data
      final report = {
        "roadName": _roadNameController.text,
        "area": _areaController.text,
        "district": _districtController.text,
        "region": _regionController.text,
        "ward": _wardController.text,
        "date": _selectedDate?.toIso8601String(),
        "type": _accidentType,
        "effects": _effectsController.text,
        "visibility": _visibilityController.text,
        "weather": _weatherController.text,
        "physiologicalIssues": _physiologyController.text,
        "environmentalFactors": _environmentController.text,
        "location": _pickedLocation,
        "additionalPoints": _additionalPoints,
        "photoUrls": _photoUrls,
        "involvedParties": _involvedParties,
        "createdAt": DateTime.now().toIso8601String(),
      };

      // TODO: Send to backend or Firebase

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Accident report submitted')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all required fields')),
      );
    }
  }

  @override
  void dispose() {
    _roadNameController.dispose();
    _areaController.dispose();
    _districtController.dispose();
    _regionController.dispose();
    _wardController.dispose();
    _effectsController.dispose();
    _visibilityController.dispose();
    _weatherController.dispose();
    _physiologyController.dispose();
    _environmentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Accident Report')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _roadNameController,
                decoration: InputDecoration(labelText: 'Road Name'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _areaController,
                decoration: InputDecoration(labelText: 'Area'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _districtController,
                decoration: InputDecoration(labelText: 'District'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _regionController,
                decoration: InputDecoration(labelText: 'Region'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _wardController,
                decoration: InputDecoration(labelText: 'Ward'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 10),
              ListTile(
                title: Text(
                  _selectedDate == null
                      ? 'Select Date'
                      : _selectedDate!.toLocal().toString().split(' ')[0],
                ),
                trailing: Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
              DropdownButtonFormField<String>(
                value: _accidentType,
                items:
                    _accidentTypes
                        .map(
                          (type) =>
                              DropdownMenuItem(value: type, child: Text(type)),
                        )
                        .toList(),
                onChanged: (val) => setState(() => _accidentType = val),
                decoration: InputDecoration(labelText: 'Accident Type'),
                validator: (val) => val == null ? 'Required' : null,
              ),
              TextFormField(
                controller: _effectsController,
                decoration: InputDecoration(labelText: 'Effects'),
              ),
              TextFormField(
                controller: _visibilityController,
                decoration: InputDecoration(labelText: 'Visibility'),
              ),
              TextFormField(
                controller: _weatherController,
                decoration: InputDecoration(labelText: 'Weather'),
              ),
              TextFormField(
                controller: _physiologyController,
                decoration: InputDecoration(labelText: 'Physiological Issues'),
              ),
              TextFormField(
                controller: _environmentController,
                decoration: InputDecoration(labelText: 'Environmental Factors'),
              ),
              SizedBox(height: 16),
              ListTile(
                title: Text(
                  _pickedLocation == null
                      ? 'Select Location'
                      : 'Lat: ${_pickedLocation!.latitude}, Lng: ${_pickedLocation!.longitude}',
                ),
                trailing: Icon(Icons.location_pin),
                onTap: _selectLocation,
              ),
              Divider(height: 30),
              Text(
                'Involved Parties',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ..._involvedParties.asMap().entries.map((entry) {
                final index = entry.key;
                final data = entry.value;
                return Column(
                  children: [
                    TextFormField(
                      initialValue: data['name'],
                      onChanged: (val) => _involvedParties[index]['name'] = val,
                      decoration: InputDecoration(labelText: 'Name'),
                    ),
                    TextFormField(
                      initialValue: data['role'],
                      onChanged: (val) => _involvedParties[index]['role'] = val,
                      decoration: InputDecoration(labelText: 'Role'),
                    ),
                    TextFormField(
                      initialValue: data['condition'],
                      onChanged:
                          (val) => _involvedParties[index]['condition'] = val,
                      decoration: InputDecoration(labelText: 'Condition'),
                    ),
                    Divider(),
                  ],
                );
              }),
              TextButton.icon(
                onPressed: _addInvolvedParty,
                icon: Icon(Icons.add),
                label: Text('Add Involved Party'),
              ),
              SizedBox(height: 16),
              Text('Photos', style: TextStyle(fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 10,
                children:
                    _photoUrls
                        .map(
                          (path) => Image.file(
                            File(path),
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        )
                        .toList(),
              ),
              TextButton.icon(
                onPressed: _pickPhoto,
                icon: Icon(Icons.photo_library),
                label: Text('Add Photo'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text('Submit Report'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
