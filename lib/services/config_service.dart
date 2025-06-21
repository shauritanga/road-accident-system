import 'package:cloud_firestore/cloud_firestore.dart';

class ConfigService {
  final FirebaseFirestore _firestore;

  ConfigService(this._firestore);

  // Get dropdown options from Firebase
  Future<List<String>> getAccidentTypes() async {
    try {
      final doc = await _firestore.collection('config').doc('accident_types').get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        return List<String>.from(data['options'] ?? []);
      }
      // Fallback to default values if not found in Firebase
      return _getDefaultAccidentTypes();
    } catch (e) {
      return _getDefaultAccidentTypes();
    }
  }

  Future<List<String>> getEffectTypes() async {
    try {
      final doc = await _firestore.collection('config').doc('effect_types').get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        return List<String>.from(data['options'] ?? []);
      }
      return _getDefaultEffectTypes();
    } catch (e) {
      return _getDefaultEffectTypes();
    }
  }

  Future<List<String>> getWeatherConditions() async {
    try {
      final doc = await _firestore.collection('config').doc('weather_conditions').get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        return List<String>.from(data['options'] ?? []);
      }
      return _getDefaultWeatherConditions();
    } catch (e) {
      return _getDefaultWeatherConditions();
    }
  }

  Future<List<String>> getVisibilityConditions() async {
    try {
      final doc = await _firestore.collection('config').doc('visibility_conditions').get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        return List<String>.from(data['options'] ?? []);
      }
      return _getDefaultVisibilityConditions();
    } catch (e) {
      return _getDefaultVisibilityConditions();
    }
  }

  Future<List<String>> getPhysiologicalIssues() async {
    try {
      final doc = await _firestore.collection('config').doc('physiological_issues').get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        return List<String>.from(data['options'] ?? []);
      }
      return _getDefaultPhysiologicalIssues();
    } catch (e) {
      return _getDefaultPhysiologicalIssues();
    }
  }

  Future<List<String>> getEnvironmentalFactors() async {
    try {
      final doc = await _firestore.collection('config').doc('environmental_factors').get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        return List<String>.from(data['options'] ?? []);
      }
      return _getDefaultEnvironmentalFactors();
    } catch (e) {
      return _getDefaultEnvironmentalFactors();
    }
  }

  Future<List<String>> getRegions() async {
    try {
      final doc = await _firestore.collection('config').doc('regions').get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        return List<String>.from(data['options'] ?? []);
      }
      return _getDefaultRegions();
    } catch (e) {
      return _getDefaultRegions();
    }
  }

  // Initialize default configuration in Firebase
  Future<void> initializeDefaultConfig() async {
    try {
      final batch = _firestore.batch();

      // Accident Types
      batch.set(_firestore.collection('config').doc('accident_types'), {
        'options': _getDefaultAccidentTypes(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      // Effect Types
      batch.set(_firestore.collection('config').doc('effect_types'), {
        'options': _getDefaultEffectTypes(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      // Weather Conditions
      batch.set(_firestore.collection('config').doc('weather_conditions'), {
        'options': _getDefaultWeatherConditions(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      // Visibility Conditions
      batch.set(_firestore.collection('config').doc('visibility_conditions'), {
        'options': _getDefaultVisibilityConditions(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      // Physiological Issues
      batch.set(_firestore.collection('config').doc('physiological_issues'), {
        'options': _getDefaultPhysiologicalIssues(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      // Environmental Factors
      batch.set(_firestore.collection('config').doc('environmental_factors'), {
        'options': _getDefaultEnvironmentalFactors(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      // Regions
      batch.set(_firestore.collection('config').doc('regions'), {
        'options': _getDefaultRegions(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      await batch.commit();
    } catch (e) {
      print('Error initializing default config: $e');
    }
  }

  // Default values (fallback)
  List<String> _getDefaultAccidentTypes() {
    return [
      'Head-on Collision',
      'Rear-end Collision',
      'Side Impact',
      'Rollover',
      'Single Vehicle',
      'Pedestrian Accident',
      'Motorcycle Accident',
      'Bicycle Accident',
      'Hit and Run',
      'Other',
    ];
  }

  List<String> _getDefaultEffectTypes() {
    return [
      'Fatal',
      'Serious Injury',
      'Minor Injury',
      'Property Damage Only',
      'No Damage',
    ];
  }

  List<String> _getDefaultWeatherConditions() {
    return [
      'Clear',
      'Rainy',
      'Foggy',
      'Cloudy',
      'Stormy',
      'Windy',
      'Other',
    ];
  }

  List<String> _getDefaultVisibilityConditions() {
    return [
      'Good',
      'Fair',
      'Poor',
      'Very Poor',
    ];
  }

  List<String> _getDefaultPhysiologicalIssues() {
    return [
      'None',
      'Fatigue',
      'Alcohol',
      'Drugs',
      'Medical Condition',
      'Distracted Driving',
      'Other',
    ];
  }

  List<String> _getDefaultEnvironmentalFactors() {
    return [
      'None',
      'Poor Road Condition',
      'Poor Lighting',
      'Road Construction',
      'Traffic Signal Issue',
      'Poor Road Markings',
      'Debris on Road',
      'Other',
    ];
  }

  List<String> _getDefaultRegions() {
    return [
      'Dar es Salaam',
      'Mwanza',
      'Arusha',
      'Dodoma',
      'Mbeya',
      'Morogoro',
      'Tanga',
      'Tabora',
      'Kigoma',
      'Mtwara',
      'Ruvuma',
      'Iringa',
      'Kagera',
      'Lindi',
      'Manyara',
      'Shinyanga',
      'Singida',
      'Rukwa',
      'Katavi',
      'Simiyu',
      'Geita',
      'Njombe',
      'Pemba North',
      'Pemba South',
      'Unguja North',
      'Unguja South',
      'Unguja West',
    ];
  }
}
