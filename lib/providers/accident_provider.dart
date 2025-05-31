import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_accident_system/models/accident_model.dart';
import 'package:road_accident_system/services/accident_service.dart';

final accidentServiceProvider = Provider<AccidentService>((ref) {
  final firestore = FirebaseFirestore.instance;
  return AccidentService(firestore);
});

final streamAccidentProvider = StreamProvider<List<Accident>>((ref) {
  return ref.watch(accidentServiceProvider).getAccidents();
});
