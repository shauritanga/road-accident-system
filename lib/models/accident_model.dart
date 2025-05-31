import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class InvolvedParty {
  final String type; // e.g., vehicle, pedestrian
  final String details; // e.g., vehicle plate, driver name

  InvolvedParty({required this.type, required this.details});

  Map<String, dynamic> toFirestore() => {'type': type, 'details': details};

  factory InvolvedParty.fromFirestore(Map<String, dynamic> data) =>
      InvolvedParty(
        type: data['type']?.toString() ?? '',
        details: data['details']?.toString() ?? '',
      );
}

class Accident {
  final String? id;
  final String roadName;
  final String area;
  final String district;
  final String region;
  final String ward;
  final DateTime date;
  final String type;
  final String effects;
  final String visibility;
  final String weather;
  final String physiologicalIssues;
  final String environmentalFactors;
  final LatLng location;
  final List<LatLng> additionalPoints;
  final List<String> photoUrls;
  final List<InvolvedParty> involvedParties;
  final DateTime createdAt;

  Accident({
    this.id,
    required this.roadName,
    required this.area,
    required this.district,
    required this.region,
    required this.ward,
    required this.date,
    required this.type,
    required this.effects,
    required this.visibility,
    required this.weather,
    required this.physiologicalIssues,
    required this.environmentalFactors,
    required this.location,
    this.additionalPoints = const [],
    this.photoUrls = const [],
    this.involvedParties = const [],
    required this.createdAt,
  });

  factory Accident.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final geoPoint = data['location'] as GeoPoint;
    final additionalPoints =
        (data['additional_points'] as List<dynamic>?)
            ?.map((p) => LatLng((p as GeoPoint).latitude, p.longitude))
            .toList() ??
        [];
    final photoUrls =
        (data['photo_urls'] as List<dynamic>?)?.cast<String>() ?? [];
    final involvedParties =
        (data['involved_parties'] as List<dynamic>?)
            ?.map((p) => InvolvedParty.fromFirestore(p as Map<String, dynamic>))
            .toList() ??
        [];
    return Accident(
      id: doc.id,
      roadName: data['road_name']?.toString() ?? '',
      area: data['area']?.toString() ?? '',
      district: data['district']?.toString() ?? '',
      region: data['region']?.toString() ?? '',
      ward: data['ward']?.toString() ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      type: data['type']?.toString() ?? '',
      effects: data['effects']?.toString() ?? '',
      visibility: data['visibility']?.toString() ?? '', // Ensure String
      weather: data['weather']?.toString() ?? '', // Ensure String
      physiologicalIssues: data['physiological_issues']?.toString() ?? '',
      environmentalFactors: data['environmental_factors']?.toString() ?? '',
      location: LatLng(geoPoint.latitude, geoPoint.longitude),
      additionalPoints: additionalPoints,
      photoUrls: photoUrls,
      involvedParties: involvedParties,
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'road_name': roadName,
      'area': area,
      'district': district,
      'region': region,
      'ward': ward,
      'date': Timestamp.fromDate(date),
      'type': type,
      'effects': effects,
      'visibility': visibility,
      'weather': weather,
      'physiological_issues': physiologicalIssues,
      'environmental_factors': environmentalFactors,
      'location': GeoPoint(location.latitude, location.longitude),
      'additional_points':
          additionalPoints
              .map((p) => GeoPoint(p.latitude, p.longitude))
              .toList(),
      'photo_urls': photoUrls,
      'involved_parties': involvedParties.map((p) => p.toFirestore()).toList(),
      'created_at': Timestamp.fromDate(createdAt),
    };
  }
}
