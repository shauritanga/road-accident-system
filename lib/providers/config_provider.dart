import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_accident_system/services/config_service.dart';

final configServiceProvider = Provider<ConfigService>((ref) {
  final firestore = FirebaseFirestore.instance;
  return ConfigService(firestore);
});

final accidentTypesProvider = FutureProvider<List<String>>((ref) async {
  final configService = ref.watch(configServiceProvider);
  return await configService.getAccidentTypes();
});

final effectTypesProvider = FutureProvider<List<String>>((ref) async {
  final configService = ref.watch(configServiceProvider);
  return await configService.getEffectTypes();
});

final weatherConditionsProvider = FutureProvider<List<String>>((ref) async {
  final configService = ref.watch(configServiceProvider);
  return await configService.getWeatherConditions();
});

final visibilityConditionsProvider = FutureProvider<List<String>>((ref) async {
  final configService = ref.watch(configServiceProvider);
  return await configService.getVisibilityConditions();
});

final physiologicalIssuesProvider = FutureProvider<List<String>>((ref) async {
  final configService = ref.watch(configServiceProvider);
  return await configService.getPhysiologicalIssues();
});

final environmentalFactorsProvider = FutureProvider<List<String>>((ref) async {
  final configService = ref.watch(configServiceProvider);
  return await configService.getEnvironmentalFactors();
});

final regionsProvider = FutureProvider<List<String>>((ref) async {
  final configService = ref.watch(configServiceProvider);
  return await configService.getRegions();
});
