import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:road_accident_system/models/accident_model.dart';

class AccidentService {
  final FirebaseFirestore _firestore;

  AccidentService(this._firestore);

  Future<void> createAccident(Accident accident) async {
    await _firestore.collection('accidents').add(accident.toFirestore());
  }

  Stream<List<Accident>> getAccidents() {
    return _firestore
        .collection('accidents')
        .orderBy('created_at', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) {
                return Accident.fromFirestore(doc);
              }).toList(),
        );
  }

  Stream<List<Accident>> getRecentAccidents({int limit = 5}) {
    return _firestore
        .collection('accidents')
        .orderBy('created_at', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) {
                return Accident.fromFirestore(doc);
              }).toList(),
        );
  }

  Future<Map<String, int>> getAccidentCountsByField(String field) async {
    final snapshot = await _firestore.collection('accidents').get();
    final counts = <String, int>{};
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final value = data[field]?.toString() ?? 'Unknown';
      counts[value] = (counts[value] ?? 0) + 1;
    }
    return counts;
  }

  Future<List<Accident>> getAccidentsByFilter({
    String? region,
    String? type,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    Query query = _firestore.collection('accidents');
    if (region != null) query = query.where('region', isEqualTo: region);
    if (type != null) query = query.where('type', isEqualTo: type);
    if (startDate != null) {
      query = query.where(
        'date',
        isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
      );
    }
    if (endDate != null) {
      query = query.where(
        'date',
        isLessThanOrEqualTo: Timestamp.fromDate(endDate),
      );
    }
    final snapshot = await query.get();
    return snapshot.docs.map((doc) => Accident.fromFirestore(doc)).toList();
  }
}
