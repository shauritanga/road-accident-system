import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:road_accident_system/models/accident_model.dart';
import 'package:road_accident_system/providers/accident_provider.dart';
import 'package:road_accident_system/providers/auth_provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class TaruraHomeScreen extends ConsumerStatefulWidget {
  const TaruraHomeScreen({super.key});

  @override
  ConsumerState createState() => _TaruraHomeScreenState();
}

class _TaruraHomeScreenState extends ConsumerState<TaruraHomeScreen>
    with SingleTickerProviderStateMixin {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  String? _selectedRegion;
  String? _selectedType;
  DateTime? _startDate;
  DateTime? _endDate;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accidentSync = ref.watch(streamAccidentProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Overview'),
            Tab(text: 'Trends'),
            Tab(text: 'Analysis'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              ref.refresh<Stream<List<Accident>>>(
                streamAccidentProvider as Refreshable<Stream<List<Accident>>>,
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => ref.read(authServiceProvider).signOut(),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(accidentSync),
          _buildTrendsTab(accidentSync),
          _buildAnalysisTab(accidentSync),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(AsyncValue<List<Accident>> accidentSync) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: accidentSync.when(
              data: (accidents) => _buildStatisticsCards(accidents),
              loading: () => Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
          if (_hasActiveFilters())
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Icon(Icons.filter_list, color: Colors.blue),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _getFilterSummary(),
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                      TextButton(
                        onPressed: _clearFilters,
                        child: Text('Clear'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          SizedBox(
            height: 400,
            child: accidentSync.when(
              data: (accidents) {
                final filteredAccidents = _filterAccidents(accidents);
                _updateMarkers(filteredAccidents);
                return GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(-6.7924, 39.2083),
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
                );
              },
              loading: () => Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendsTab(AsyncValue<List<Accident>> accidentSync) {
    return accidentSync.when(
      data: (accidents) {
        final filteredAccidents = _filterAccidents(accidents);
        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Accident Trends',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 24),
              _buildMonthlyTrendChart(filteredAccidents),
              SizedBox(height: 24),
              _buildTypeDistributionChart(filteredAccidents),
              SizedBox(height: 24),
              _buildWeatherImpactChart(filteredAccidents),
            ],
          ),
        );
      },
      loading: () => Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildAnalysisTab(AsyncValue<List<Accident>> accidentSync) {
    return accidentSync.when(
      data: (accidents) {
        final filteredAccidents = _filterAccidents(accidents);
        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Accident Analysis',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 24),
              _buildHighRiskAreasAnalysis(filteredAccidents),
              SizedBox(height: 24),
              _buildTimeAnalysis(filteredAccidents),
              SizedBox(height: 24),
              _buildEnvironmentalFactorsAnalysis(filteredAccidents),
            ],
          ),
        );
      },
      loading: () => Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildMonthlyTrendChart(List<Accident> accidents) {
    final monthlyData = <String, int>{};
    for (var accident in accidents) {
      final month = DateFormat('MMM yyyy').format(accident.date);
      monthlyData[month] = (monthlyData[month] ?? 0) + 1;
    }

    final spots =
        monthlyData.entries.map((entry) {
          return FlSpot(
            monthlyData.keys.toList().indexOf(entry.key).toDouble(),
            entry.value.toDouble(),
          );
        }).toList();

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Accident Trends',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 &&
                              value.toInt() < monthlyData.length) {
                            return Text(
                              monthlyData.keys.elementAt(value.toInt()),
                            );
                          }
                          return Text('');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeDistributionChart(List<Accident> accidents) {
    final typeData = <String, int>{};
    for (var accident in accidents) {
      typeData[accident.type] = (typeData[accident.type] ?? 0) + 1;
    }

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Accident Type Distribution',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections:
                      typeData.entries.map((entry) {
                        return PieChartSectionData(
                          value: entry.value.toDouble(),
                          title: '${entry.key}\n${entry.value}',
                          radius: 100,
                          titleStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherImpactChart(List<Accident> accidents) {
    final weatherData = <String, int>{};
    for (var accident in accidents) {
      weatherData[accident.weather] = (weatherData[accident.weather] ?? 0) + 1;
    }

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weather Impact Analysis',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY:
                      weatherData.values
                          .reduce((a, b) => a > b ? a : b)
                          .toDouble(),
                  barGroups:
                      weatherData.entries.map((entry) {
                        return BarChartGroupData(
                          x: weatherData.keys.toList().indexOf(entry.key),
                          barRods: [
                            BarChartRodData(
                              toY: entry.value.toDouble(),
                              color: Colors.blue,
                              width: 20,
                            ),
                          ],
                        );
                      }).toList(),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 &&
                              value.toInt() < weatherData.length) {
                            return Text(
                              weatherData.keys.elementAt(value.toInt()),
                              style: TextStyle(fontSize: 10),
                            );
                          }
                          return Text('');
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHighRiskAreasAnalysis(List<Accident> accidents) {
    final locationCounts = <String, int>{};
    for (var accident in accidents) {
      locationCounts[accident.roadName] =
          (locationCounts[accident.roadName] ?? 0) + 1;
    }

    final highRiskAreas =
        locationCounts.entries.where((e) => e.value > 1).toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'High Risk Areas',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 16),
            ...highRiskAreas
                .take(5)
                .map(
                  (area) => ListTile(
                    title: Text(area.key),
                    subtitle: Text('${area.value} accidents reported'),
                    trailing: Icon(Icons.warning, color: Colors.orange),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeAnalysis(List<Accident> accidents) {
    final hourlyData = List.filled(24, 0);
    for (var accident in accidents) {
      hourlyData[accident.date.hour]++;
    }

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Time of Day Analysis',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: hourlyData.reduce((a, b) => a > b ? a : b).toDouble(),
                  barGroups: List.generate(24, (index) {
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: hourlyData[index].toDouble(),
                          color: Colors.blue,
                          width: 20,
                        ),
                      ],
                    );
                  }),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toInt()}:00');
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnvironmentalFactorsAnalysis(List<Accident> accidents) {
    final factors = <String, int>{};
    for (var accident in accidents) {
      if (accident.environmentalFactors.isNotEmpty) {
        factors[accident.environmentalFactors] =
            (factors[accident.environmentalFactors] ?? 0) + 1;
      }
    }

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Environmental Factors',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 16),
            ...factors.entries.map(
              (factor) => ListTile(
                title: Text(factor.key),
                subtitle: Text('${factor.value} accidents'),
                trailing: Text(
                  '${(factor.value / accidents.length * 100).toStringAsFixed(1)}%',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCards(List<Accident> accidents) {
    final totalAccidents = accidents.length;
    final highRiskAreas = _analyzeLocations(accidents);
    final weatherConditions = _analyzeConditions(accidents);

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildStatCard(
          'Total Accidents',
          totalAccidents.toString(),
          Icons.warning,
          Colors.red,
        ),
        _buildStatCard(
          'High Risk Areas',
          highRiskAreas.split(',').length.toString(),
          Icons.location_on,
          Colors.orange,
        ),
        _buildStatCard(
          'Weather Conditions',
          weatherConditions.length.toString(),
          Icons.cloud,
          Colors.blue,
        ),
        _buildStatCard(
          'Recent Accidents',
          accidents
              .where((a) => DateTime.now().difference(a.date).inDays <= 7)
              .length
              .toString(),
          Icons.access_time,
          Colors.green,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  LatLngBounds _calculateBounds(List<Accident> accidents) {
    final allPoints =
        accidents.expand((a) => [a.location, ...a.additionalPoints]).toList();
    final latitudes = allPoints.map((p) => p.latitude).toList();
    final longitudes = allPoints.map((p) => p.longitude).toList();
    final minLat = latitudes.reduce((a, b) => a < b ? a : b);
    final maxLat = latitudes.reduce((a, b) => a > b ? a : b);
    final minLng = longitudes.reduce((a, b) => a < b ? a : b);
    final maxLng = longitudes.reduce((a, b) => a > b ? a : b);
    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  String _analyzeLocations(List<Accident> accidents) {
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
      if (accident.weather.isNotEmpty) {
        conditions.add(accident.weather);
      }
      if (accident.visibility.isNotEmpty) {
        conditions.add(accident.visibility);
      }
    }
    return conditions.toList();
  }

  bool _hasActiveFilters() {
    return _selectedRegion != null ||
        _selectedType != null ||
        _startDate != null ||
        _endDate != null;
  }

  String _getFilterSummary() {
    final filters = <String>[];
    if (_selectedRegion != null) filters.add('Region: $_selectedRegion');
    if (_selectedType != null) filters.add('Type: $_selectedType');
    if (_startDate != null) {
      filters.add('From: ${_startDate!.toString().split(' ')[0]}');
    }
    if (_endDate != null) {
      filters.add('To: ${_endDate!.toString().split(' ')[0]}');
    }
    return filters.join(' | ');
  }

  void _clearFilters() {
    setState(() {
      _selectedRegion = null;
      _selectedType = null;
      _startDate = null;
      _endDate = null;
    });
  }

  List<Accident> _filterAccidents(List<Accident> accidents) {
    return accidents.where((accident) {
      if (_selectedRegion != null && accident.region != _selectedRegion) {
        return false;
      }
      if (_selectedType != null && accident.type != _selectedType) {
        return false;
      }
      if (_startDate != null && accident.date.isBefore(_startDate!)) {
        return false;
      }
      if (_endDate != null && accident.date.isAfter(_endDate!)) {
        return false;
      }
      return true;
    }).toList();
  }

  Future<void> _showFilterDialog() async {
    final accidentSync = ref.read(streamAccidentProvider);
    final accidents = accidentSync.when(
      data: (data) => data,
      loading: () => <Accident>[],
      error: (_, __) => <Accident>[],
    );

    final regions = accidents.map((a) => a.region).toSet().toList();
    final types = accidents.map((a) => a.type).toSet().toList();

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Filter Accidents'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedRegion,
                    decoration: InputDecoration(labelText: 'Region'),
                    items: [
                      DropdownMenuItem(value: null, child: Text('All Regions')),
                      ...regions.map(
                        (r) => DropdownMenuItem(value: r, child: Text(r)),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedRegion = value);
                    },
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration: InputDecoration(labelText: 'Accident Type'),
                    items: [
                      DropdownMenuItem(value: null, child: Text('All Types')),
                      ...types.map(
                        (t) => DropdownMenuItem(value: t, child: Text(t)),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedType = value);
                    },
                  ),
                  SizedBox(height: 16),
                  ListTile(
                    title: Text('Date Range'),
                    subtitle: Text(
                      _startDate == null && _endDate == null
                          ? 'Select date range'
                          : '${_startDate?.toString().split(' ')[0] ?? 'Any'} - ${_endDate?.toString().split(' ')[0] ?? 'Any'}',
                    ),
                    trailing: Icon(Icons.calendar_today),
                    onTap: () async {
                      final DateTimeRange? dateRange =
                          await showDateRangePicker(
                            context: context,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                            initialDateRange:
                                _startDate != null && _endDate != null
                                    ? DateTimeRange(
                                      start: _startDate!,
                                      end: _endDate!,
                                    )
                                    : null,
                          );
                      if (dateRange != null) {
                        setState(() {
                          _startDate = dateRange.start;
                          _endDate = dateRange.end;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _clearFilters();
                },
                child: Text('Clear'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Apply'),
              ),
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
              ),
            ];
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            expand: false,
            builder:
                (context, scrollController) => SingleChildScrollView(
                  controller: scrollController,
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Accident Details',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      Divider(),
                      _buildDetailItem('Road Name', accident.roadName),
                      _buildDetailItem('Area', accident.area),
                      _buildDetailItem('District', accident.district),
                      _buildDetailItem('Region', accident.region),
                      _buildDetailItem('Ward', accident.ward),
                      _buildDetailItem(
                        'Date',
                        DateFormat('MMM dd, yyyy').format(accident.date),
                      ),
                      _buildDetailItem('Type', accident.type),
                      _buildDetailItem('Effects', accident.effects),
                      _buildDetailItem('Weather', accident.weather),
                      _buildDetailItem('Visibility', accident.visibility),
                      _buildDetailItem(
                        'Physiological Issues',
                        accident.physiologicalIssues,
                      ),
                      _buildDetailItem(
                        'Environmental Factors',
                        accident.environmentalFactors,
                      ),
                      if (accident.photoUrls.isNotEmpty) ...[
                        SizedBox(height: 16),
                        Text(
                          'Photos',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        SizedBox(height: 8),
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: accident.photoUrls.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: EdgeInsets.only(right: 8),
                                child: Image.network(
                                  accident.photoUrls[index],
                                  height: 100,
                                  width: 100,
                                  fit: BoxFit.cover,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                      if (accident.involvedParties.isNotEmpty) ...[
                        SizedBox(height: 16),
                        Text(
                          'Involved Parties',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        SizedBox(height: 8),
                        ...accident.involvedParties.map(
                          (party) => Card(
                            child: ListTile(
                              title: Text(party.type),
                              subtitle: Text(party.details),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
          ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
