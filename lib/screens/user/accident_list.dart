import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:road_accident_system/models/accident_model.dart';
import 'package:road_accident_system/providers/accident_provider.dart';

class AccidentListScreen extends ConsumerWidget {
  const AccidentListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accidentService = ref.watch(accidentServiceProvider);
    final accidentsStream = ref.watch(
      Provider((ref) => accidentService.getAccidents()),
    );

    return Scaffold(
      appBar: AppBar(title: Text('Accident Reports')),
      body: StreamBuilder<List<Accident>>(
        stream: accidentsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final accidents = snapshot.data!;
          final frequentLocations = _analyzeLocations(accidents);
          final commonConditions = _analyzeConditions(accidents);

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: accidents.length,
                  itemBuilder: (context, index) {
                    final accident = accidents[index];
                    return ListTile(
                      title: Text('Accident on ${accident.roadName}'),
                      subtitle: Text(
                        'Date: ${DateFormat.yMd().format(accident.date)}, Type: ${accident.type}',
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Proposed Solutions:',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    if (frequentLocations.isNotEmpty)
                      Text(
                        '• Frequent accident locations: $frequentLocations. Suggested: Install warning signs and speed bumps.',
                      ),
                    if (commonConditions.contains('Rainy'))
                      Text(
                        '• Rainy conditions detected. Suggested: Improve drainage systems and road grip.',
                      ),
                    if (commonConditions.contains('Dark'))
                      Text(
                        '• Poor visibility at night. Suggested: Install street lighting.',
                      ),
                    Text(
                      '• General: Conduct driver awareness campaigns to address physiological issues.',
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _analyzeLocations(List accidents) {
    final locationCounts = <String, int>{};
    for (var accident in accidents) {
      locationCounts[accident.roadName] =
          (locationCounts[accident.roadName] ?? 0) + 1;
    }
    return locationCounts.entries
        .where((e) => e.value > 1)
        .map((e) => e.key)
        .join(', ');
  }

  List<String> _analyzeConditions(List<Accident> accidents) {
    final conditions = <String>{};
    for (var accident in accidents) {
      conditions.add(accident.weather);
      conditions.add(accident.visibility);
    }
    return conditions.toList();
  }
}
