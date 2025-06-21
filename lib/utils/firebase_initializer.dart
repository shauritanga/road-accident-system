import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:road_accident_system/services/config_service.dart';

class FirebaseInitializer {
  static Future<void> initializeAppData() async {
    try {
      final configService = ConfigService(FirebaseFirestore.instance);
      
      // Check if configuration already exists
      final doc = await FirebaseFirestore.instance
          .collection('config')
          .doc('accident_types')
          .get();
      
      if (!doc.exists) {
        print('Initializing Firebase configuration data...');
        await configService.initializeDefaultConfig();
        print('Firebase configuration data initialized successfully.');
      } else {
        print('Firebase configuration data already exists.');
      }
    } catch (e) {
      print('Error initializing Firebase data: $e');
    }
  }
}
