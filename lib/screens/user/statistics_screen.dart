import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:road_accident_system/models/accident_model.dart';
import 'package:road_accident_system/providers/accident_provider.dart';
import 'package:road_accident_system/utils/report_generator.dart';
import 'package:share_plus/share_plus.dart';

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  String _timeFilter = 'Last 30 Days';
  String _regionFilter = 'All Regions';
  String _severityFilter = 'All Severities';
  String _typeFilter = 'All Types';
  bool _isAdvancedFilterVisible = false;
  late TabController _tabController;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isCustomDateRange = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accidentsStream = ref.watch(streamAccidentProvider);
    final primaryColor = Theme.of(context).primaryColor;
    final primaryColorDark =
        HSLColor.fromColor(primaryColor)
            .withLightness(
              (HSLColor.fromColor(primaryColor).lightness - 0.1).clamp(
                0.0,
                1.0,
              ),
            )
            .toColor();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Accident Statistics'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4, // Increased elevation for better shadow
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            tooltip: 'Export Report',
            onPressed: () => _showExportOptions(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Data',
            onPressed: () {
              ref.refresh(streamAccidentProvider);
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3.0, // Thicker indicator for better visibility
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold, // Bold text for selected tab
            fontSize: 14,
            color: Colors.white,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 14,
            color: Colors.grey[500],
          ),

          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Trends'),
            Tab(text: 'Analysis'),
            Tab(text: 'Comparison'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Header with filters
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [primaryColorDark, primaryColor],
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.analytics,
                        color: primaryColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ROAD SAFETY ANALYTICS',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Comprehensive analysis of road accident data',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _isAdvancedFilterVisible
                            ? Icons.expand_less
                            : Icons.expand_more,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          _isAdvancedFilterVisible = !_isAdvancedFilterVisible;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildFilterDropdown(
                        'Time Period',
                        _timeFilter,
                        [
                          'Last 7 Days',
                          'Last 30 Days',
                          'Last 90 Days',
                          'This Year',
                          'Custom Range',
                        ],
                        (value) {
                          setState(() {
                            _timeFilter = value!;
                            _isCustomDateRange = value == 'Custom Range';
                            if (!_isCustomDateRange) {
                              _startDate = null;
                              _endDate = null;
                            }
                          });
                          if (_isCustomDateRange) {
                            _showDateRangePicker();
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildFilterDropdown(
                        'Region',
                        _regionFilter,
                        [
                          'All Regions',
                          'Dar es Salaam',
                          'Arusha',
                          'Mwanza',
                          'Dodoma',
                          'Mbeya',
                          'Tanga',
                        ],
                        (value) {
                          setState(() {
                            _regionFilter = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                if (_isAdvancedFilterVisible) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildFilterDropdown(
                          'Severity',
                          _severityFilter,
                          [
                            'All Severities',
                            'Fatal',
                            'Serious Injury',
                            'Minor Injury',
                            'Property Damage',
                          ],
                          (value) {
                            setState(() {
                              _severityFilter = value!;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildFilterDropdown(
                          'Accident Type',
                          _typeFilter,
                          [
                            'All Types',
                            'Vehicle-Vehicle',
                            'Vehicle-Pedestrian',
                            'Vehicle-Motorcycle',
                            'Single Vehicle',
                            'Multiple Vehicle',
                          ],
                          (value) {
                            setState(() {
                              _typeFilter = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  if (_isCustomDateRange &&
                      (_startDate != null || _endDate != null))
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.date_range,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Date Range: ${_startDate != null ? DateFormat('MMM d, y').format(_startDate!) : 'Any'} - ${_endDate != null ? DateFormat('MMM d, y').format(_endDate!) : 'Present'}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
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
                              child: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),

          // Statistics content
          Expanded(
            child: accidentsStream.when(
              data: (accidents) {
                // Apply filters
                final filteredAccidents = _filterAccidents(accidents);

                if (filteredAccidents.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bar_chart_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No accident data available for the selected filters',
                          style: TextStyle(color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _timeFilter = 'Last 30 Days';
                              _regionFilter = 'All Regions';
                              _severityFilter = 'All Severities';
                              _typeFilter = 'All Types';
                              _startDate = null;
                              _endDate = null;
                              _isCustomDateRange = false;
                            });
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reset Filters'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(filteredAccidents),
                    _buildTrendsTab(filteredAccidents),
                    _buildAnalysisTab(filteredAccidents),
                    _buildComparisonTab(filteredAccidents),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (error, stack) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading data: $error',
                          style: TextStyle(color: Colors.grey[700]),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            ref.refresh(streamAccidentProvider);
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showExportOptions(context),
        backgroundColor: primaryColor,
        tooltip: 'Share or Export',
        child: const Icon(Icons.share, color: Colors.white),
      ),
    );
  }

  Widget _buildOverviewTab(List<Accident> accidents) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCards(accidents),
          const SizedBox(height: 24),
          _buildSectionHeader('Key Insights', Icons.lightbulb_outline),
          const SizedBox(height: 16),
          _buildInsightsCard(accidents),
          const SizedBox(height: 24),
          _buildSectionHeader('Accident Distribution', Icons.pie_chart_outline),
          const SizedBox(height: 16),
          _buildTypesChart(accidents),
          const SizedBox(height: 24),
          _buildSectionHeader('Severity Breakdown', Icons.warning_amber),
          const SizedBox(height: 16),
          _buildSeverityChart(accidents),
          const SizedBox(height: 24),
          _buildSectionHeader('Recent Accidents', Icons.access_time),
          const SizedBox(height: 16),
          _buildRecentAccidentsList(accidents),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildTrendsTab(List<Accident> accidents) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Monthly Trends', Icons.trending_up),
          const SizedBox(height: 16),
          _buildTrendsChart(accidents),
          const SizedBox(height: 24),
          _buildSectionHeader('Weekly Distribution', Icons.date_range),
          const SizedBox(height: 16),
          _buildWeekdayChart(accidents),
          const SizedBox(height: 24),
          _buildSectionHeader('Time of Day', Icons.access_time),
          const SizedBox(height: 16),
          _buildTimeOfDayChart(accidents),
          const SizedBox(height: 24),
          _buildSectionHeader('Seasonal Patterns', Icons.wb_sunny_outlined),
          const SizedBox(height: 16),
          _buildSeasonalChart(accidents),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildAnalysisTab(List<Accident> accidents) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Contributing Factors', Icons.category),
          const SizedBox(height: 16),
          _buildContributingFactorsChart(accidents),
          const SizedBox(height: 24),
          _buildSectionHeader('Road Conditions', Icons.add_road_outlined),
          const SizedBox(height: 16),
          _buildRoadConditionsChart(accidents),
          const SizedBox(height: 24),
          _buildSectionHeader('Weather Impact', Icons.cloud_outlined),
          const SizedBox(height: 16),
          _buildWeatherImpactChart(accidents),
          const SizedBox(height: 24),
          _buildSectionHeader('Vehicle Types Involved', Icons.commute_outlined),
          const SizedBox(height: 16),
          _buildVehicleTypesChart(accidents),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildComparisonTab(List<Accident> accidents) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Regional Comparison',
            Icons.location_city_outlined,
          ),
          const SizedBox(height: 16),
          _buildRegionalComparisonChart(accidents),
          const SizedBox(height: 24),
          _buildSectionHeader(
            'Year-over-Year Comparison',
            Icons.compare_arrows,
          ),
          const SizedBox(height: 16),
          _buildYearComparisonChart(accidents),
          const SizedBox(height: 24),
          _buildSeverityByRegionChart(accidents),
          const SizedBox(height: 24),
          _buildSectionHeader('Urban vs Rural', Icons.domain_outlined),
          const SizedBox(height: 16),
          _buildUrbanRuralComparisonChart(accidents),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(
    String label,
    String value,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
          DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            icon: const Icon(Icons.arrow_drop_down, size: 20),
            style: TextStyle(color: Colors.grey[800], fontSize: 13),
            items:
                items.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[700]),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCards(List<Accident> accidents) {
    final totalAccidents = accidents.length;
    final fatalAccidents = accidents.where((a) => a.effects == 'Fatal').length;
    final injuryAccidents = accidents
        .where((a) =>
            a.effects == 'Serious Injury' ||
            a.effects == 'Minor Injury')
        .length;
    final recentAccidents =
        accidents
            .where((a) => DateTime.now().difference(a.date).inDays <= 7)
            .length;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: [
        _buildStatCard(
          'Total Accidents',
          totalAccidents.toString(),
          Icons.warning,
          Colors.blue[700]!,
        ),
        _buildStatCard(
          'Fatal Accidents',
          fatalAccidents.toString(),
          Icons.dangerous,
          Colors.red[700]!,
        ),
        _buildStatCard(
          'Injury Accidents',
          injuryAccidents.toString(),
          Icons.local_hospital,
          Colors.orange[700]!,
        ),
        _buildStatCard(
          'Recent (7 Days)',
          recentAccidents.toString(),
          Icons.access_time,
          Colors.green[700]!,
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
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsCard(List<Accident> accidents) {
    // Calculate some insights
    final mostCommonType = _getMostCommonValue(
      accidents.map((a) => a.type).toList(),
    );
    final mostDangerousTime = _getMostDangerousTimeOfDay(accidents);
    final mostDangerousDay = _getMostDangerousDay(accidents);
    final highRiskAreas = _getHighRiskAreas(accidents);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Key Insights',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInsightItem(
                    'Most Common Accident Type',
                    mostCommonType,
                    Icons.category,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInsightItem(
                    'Most Dangerous Time of Day',
                    mostDangerousTime,
                    Icons.access_time,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInsightItem(
                    'Most Dangerous Day of the Week',
                    mostDangerousDay,
                    Icons.calendar_today,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInsightItem(
                    'High-Risk Areas',
                    highRiskAreas.join(', '),
                    Icons.location_on,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightItem(String title, String? value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Colors.grey[700]),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          value ?? 'N/A',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String? _getMostCommonValue(List<String> values) {
    if (values.isEmpty) return null;

    final valueCounts = values.fold<Map<String, int>>({}, (acc, value) {
      acc[value] = (acc[value] ?? 0) + 1;
      return acc;
    });

    return valueCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  String? _getMostDangerousTimeOfDay(List<Accident> accidents) {
    final timeCounts = accidents.fold<Map<String, int>>({}, (acc, accident) {
      final hour = accident.date.hour;
      final time =
          '${hour % 12 == 0 ? 12 : hour % 12}${hour < 12 ? 'AM' : 'PM'}';
      acc[time] = (acc[time] ?? 0) + 1;
      return acc;
    });

    if (timeCounts.isEmpty) return null;

    final mostDangerousTime =
        timeCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    return mostDangerousTime;
  }

  String? _getMostDangerousDay(List<Accident> accidents) {
    final dayCounts = accidents.fold<Map<String, int>>({}, (acc, accident) {
      final day = DateFormat('EEEE').format(accident.date);
      acc[day] = (acc[day] ?? 0) + 1;
      return acc;
    });

    if (dayCounts.isEmpty) return null;

    final mostDangerousDay =
        dayCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    return mostDangerousDay;
  }

  List<String> _getHighRiskAreas(List<Accident> accidents) {
    final areaCounts = accidents.fold<Map<String, int>>({}, (acc, accident) {
      acc[accident.region] = (acc[accident.region] ?? 0) + 1;
      return acc;
    });

    if (areaCounts.isEmpty) return [];

    final sortedAreas =
        areaCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return sortedAreas.take(3).map((entry) => entry.key).toList();
  }

  Widget _buildTrendsChart(List<Accident> accidents) {
    // Group accidents by month
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
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Accident Trends',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 10,
                    getDrawingHorizontalLine:
                        (value) =>
                            FlLine(color: Colors.grey[300]!, strokeWidth: 1),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          if (value == 0) return const Text('');
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 &&
                              value.toInt() < monthlyData.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                monthlyData.keys.elementAt(value.toInt()),
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[300]!),
                      left: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Theme.of(context).primaryColor,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Theme.of(context).primaryColor.withOpacity(0.2),
                      ),
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

  Widget _buildTypesChart(List<Accident> accidents) {
    final typeData = <String, int>{};
    for (var accident in accidents) {
      typeData[accident.type] = (typeData[accident.type] ?? 0) + 1;
    }

    return _buildPieChartWithLegend(typeData, [
      Colors.blue[700]!,
      Colors.red[700]!,
      Colors.green[700]!,
      Colors.orange[700]!,
      Colors.purple[700]!,
      Colors.teal[700]!,
    ], 'Accident Type Distribution');
  }

  Widget _buildSeverityChart(List<Accident> accidents) {
    // Group accidents by severity
    final severityData = <String, int>{};
    for (var accident in accidents) {
      severityData[accident.effects] =
          (severityData[accident.effects] ?? 0) + 1;
    }

    return _buildPieChartWithLegend(severityData, [
      Colors.red[700]!,
      Colors.orange[700]!,
      Colors.yellow[700]!,
      Colors.blue[700]!,
    ], 'Accident Severity Analysis');
  }

  Widget _buildPieChartWithLegend(
    Map<String, int> data,
    List<Color> colors,
    String title,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 250, // Increased height for better fit
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: PieChart(
                      PieChartData(
                        sections:
                            data.entries.map((entry) {
                              final index = data.keys.toList().indexOf(
                                entry.key,
                              );
                              return PieChartSectionData(
                                value: entry.value.toDouble(),
                                title:
                                    '${(entry.value / data.entries.map((e) => e.value).reduce((a, b) => a + b) * 100).toStringAsFixed(1)}%',
                                radius: 90, // Slightly smaller radius
                                titleStyle: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                color: colors[index % colors.length],
                                titlePositionPercentageOffset:
                                    0.55, // Better position for labels
                              );
                            }).toList(),
                        sectionsSpace: 2,
                        centerSpaceRadius: 30,
                        centerSpaceColor: Colors.white,
                      ),
                    ),
                  ),
                  // Expanded(
                  //   flex: 2,
                  //   child: SingleChildScrollView(
                  //     // Added scrolling for legends with many items
                  //     child: Column(
                  //       mainAxisAlignment: MainAxisAlignment.center,
                  //       crossAxisAlignment: CrossAxisAlignment.start,
                  //       children:
                  //           data.entries.map((entry) {
                  //             final index = data.keys.toList().indexOf(
                  //               entry.key,
                  //             );
                  //             return Padding(
                  //               padding: const EdgeInsets.symmetric(
                  //                 vertical: 4.0,
                  //               ),
                  //               child: _buildLegendItem(
                  //                 entry.key,
                  //                 entry.value.toString(),
                  //                 colors[index % colors.length],
                  //               ),
                  //             );
                  //           }).toList(),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentAccidentsList(List<Accident> accidents) {
    final recentAccidents =
        List<Accident>.from(accidents)
          ..sort((a, b) => b.date.compareTo(a.date))
          ..take(5);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Incidents',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            ...recentAccidents.map(
              (accident) => _buildAccidentListItem(accident),
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton.icon(
                onPressed: () {
                  // Navigate to detailed accident list
                },
                icon: const Icon(Icons.list, size: 16),
                label: const Text('View All Accidents'),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccidentListItem(Accident accident) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getSeverityColor(
                accident.effects,
              ).withAlpha((0.2 * 255).round()),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getAccidentTypeIcon(accident.type),
              color: _getSeverityColor(accident.effects),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        accident.roadName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      DateFormat('MMM d, y').format(accident.date),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${accident.type} • ${accident.effects}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getAccidentTypeIcon(String type) {
    switch (type) {
      case 'Vehicle-Vehicle':
        return Icons.car_crash;
      case 'Vehicle-Pedestrian':
        return Icons.directions_walk;
      case 'Vehicle-Motorcycle':
        return Icons.motorcycle;
      case 'Single Vehicle':
        return Icons.directions_car;
      case 'Multiple Vehicle':
        return Icons.commute;
      default:
        return Icons.warning;
    }
  }

  Widget _buildWeekdayChart(List<Accident> accidents) {
    // Group accidents by day of week
    final weekdayData = <String, int>{
      'Monday': 0,
      'Tuesday': 0,
      'Wednesday': 0,
      'Thursday': 0,
      'Friday': 0,
      'Saturday': 0,
      'Sunday': 0,
    };

    for (var accident in accidents) {
      final weekday = DateFormat('EEEE').format(accident.date);
      weekdayData[weekday] = (weekdayData[weekday] ?? 0) + 1;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Accidents by Day of Week',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY:
                      weekdayData.values
                          .fold(0, (max, value) => value > max ? value : max)
                          .toDouble() *
                      1.2,
                  barGroups:
                      weekdayData.entries.map((entry) {
                        return BarChartGroupData(
                          x: weekdayData.keys.toList().indexOf(entry.key),
                          barRods: [
                            BarChartRodData(
                              toY: entry.value.toDouble(),
                              color: Theme.of(context).primaryColor,
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
                              value.toInt() < weekdayData.length) {
                            return Text(
                              weekdayData.keys.elementAt(value.toInt()),
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return const Text('');
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

  Widget _buildTimeOfDayChart(List<Accident> accidents) {
    // Group accidents by hour of day
    final hourlyData = List.filled(24, 0);
    for (var accident in accidents) {
      hourlyData[accident.date.hour]++;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Time of Day Analysis',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY:
                      hourlyData
                          .fold(0, (max, value) => value > max ? value : max)
                          .toDouble(),
                  barGroups: List.generate(24, (index) {
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: hourlyData[index].toDouble(),
                          color: Theme.of(context).primaryColor,
                          width: 8,
                        ),
                      ],
                    );
                  }),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          // Only show every 3 hours to avoid crowding
                          if (value.toInt() % 3 == 0) {
                            return Text(
                              '${value.toInt()}:00',
                              style: const TextStyle(fontSize: 9),
                            );
                          }
                          return const Text('');
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

  Widget _buildSeasonalChart(List<Accident> accidents) {
    final seasonData = <String, int>{};
    for (var accident in accidents) {
      final month = accident.date.month;
      String season;
      if (month >= 3 && month <= 5) {
        season = 'Spring';
      } else if (month >= 6 && month <= 8) {
        season = 'Summer';
      } else if (month >= 9 && month <= 11) {
        season = 'Fall';
      } else {
        season = 'Winter';
      }
      seasonData[season] = (seasonData[season] ?? 0) + 1;
    }

    return _buildPieChartWithLegend(seasonData, [
      Colors.blue[700]!,
      Colors.red[700]!,
      Colors.green[700]!,
      Colors.orange[700]!,
      Colors.purple[700]!,
      Colors.teal[700]!,
    ], 'Seasonal Accident Distribution');
  }

  Widget _buildSeasonalInsight(
    Map<String, int> seasonData,
    int totalAccidents,
  ) {
    // Find the season with the highest accident count
    final highestSeason =
        seasonData.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    // Calculate the percentage
    final highestCount = seasonData[highestSeason]!;
    final percentage = (highestCount / totalAccidents * 100).toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 20, color: Colors.grey[700]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$highestSeason has the highest accident rate ($percentage% of all accidents), suggesting seasonal factors may influence road safety.',
              style: TextStyle(fontSize: 12, color: Colors.grey[800]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey[800]),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  List<Accident> _filterAccidents(List<Accident> accidents) {
    // Apply time filter
    final now = DateTime.now();
    final filtered =
        accidents.where((accident) {
          final difference = now.difference(accident.date).inDays;

          switch (_timeFilter) {
            case 'Last 7 Days':
              return difference <= 7;
            case 'Last 30 Days':
              return difference <= 30;
            case 'Last 90 Days':
              return difference <= 90;
            case 'This Year':
              return accident.date.year == now.year;
            default:
              return true;
          }
        }).toList();

    // Apply region filter
    if (_regionFilter != 'All Regions') {
      return filtered
          .where((accident) => accident.region.contains(_regionFilter))
          .toList();
    }

    return filtered;
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'Fatal':
        return Colors.red[700]!;
      case 'Serious Injury':
        return Colors.orange[700]!;
      case 'Minor Injury':
        return Colors.yellow[700]!;
      case 'Property Damage':
        return Colors.blue[700]!;
      default:
        return Colors.grey[700]!;
    }
  }

  Widget _buildUrbanRuralComparisonChart(List<Accident> accidents) {
    // Group accidents by urban/rural areas
    final urbanCount =
        accidents.where((a) => a.area.toLowerCase().contains('urban')).length;
    final ruralCount = accidents.length - urbanCount;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Urban vs Rural Accidents',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: PieChart(
                      PieChartData(
                        sections: [
                          PieChartSectionData(
                            value: urbanCount.toDouble(),
                            title:
                                '${(urbanCount / accidents.length * 100).toStringAsFixed(1)}%',
                            radius: 100,
                            titleStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            color: Colors.blue[400],
                          ),
                          PieChartSectionData(
                            value: ruralCount.toDouble(),
                            title:
                                '${(ruralCount / accidents.length * 100).toStringAsFixed(1)}%',
                            radius: 100,
                            titleStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            color: Colors.green[400],
                          ),
                        ],
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildLegendItem(
                          'Urban',
                          urbanCount.toString(),
                          Colors.blue[400]!,
                        ),
                        const SizedBox(height: 16),
                        _buildLegendItem(
                          'Rural',
                          ruralCount.toString(),
                          Colors.green[400]!,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYearComparisonChart(List<Accident> accidents) {
    // Group accidents by year
    final yearData = <int, int>{};
    final currentYear = DateTime.now().year;
    final previousYear = currentYear - 1;

    // Initialize with zero values for both years
    yearData[previousYear] = 0;
    yearData[currentYear] = 0;

    for (var accident in accidents) {
      final year = accident.date.year;
      if (year == currentYear || year == previousYear) {
        yearData[year] = (yearData[year] ?? 0) + 1;
      }
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Year-over-Year Comparison',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY:
                      yearData.values
                          .fold(0, (max, value) => value > max ? value : max)
                          .toDouble() *
                      1.2,
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: yearData[previousYear]!.toDouble(),
                          color: Colors.orange[400],
                          width: 40,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                          toY: yearData[currentYear]!.toDouble(),
                          color: Theme.of(context).primaryColor,
                          width: 40,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ],
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt() == 0
                                ? previousYear.toString()
                                : currentYear.toString(),
                            style: const TextStyle(fontSize: 12),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                        reservedSize: 30,
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    drawHorizontalLine: true,
                    horizontalInterval: 10,
                    getDrawingHorizontalLine:
                        (value) =>
                            FlLine(color: Colors.grey[300]!, strokeWidth: 1),
                  ),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(
                  previousYear.toString(),
                  yearData[previousYear].toString(),
                  Colors.orange[400]!,
                ),
                const SizedBox(width: 24),
                _buildLegendItem(
                  currentYear.toString(),
                  yearData[currentYear].toString(),
                  Theme.of(context).primaryColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showExportOptions(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (context) => Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Export Statistics',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: Icon(Icons.picture_as_pdf, color: primaryColor),
                  title: const Text('Export as PDF'),
                  subtitle: const Text('Generate a detailed PDF report'),
                  onTap: () {
                    Navigator.pop(context);
                    _exportAsPdf();
                  },
                ),
                const Divider(),
                ListTile(
                  leading: Icon(Icons.table_chart, color: primaryColor),
                  title: const Text('Export as CSV'),
                  subtitle: const Text(
                    'Export raw data for spreadsheet analysis',
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _exportAsCsv();
                  },
                ),
                const Divider(),
                ListTile(
                  leading: Icon(Icons.share, color: primaryColor),
                  title: const Text('Share Statistics'),
                  subtitle: const Text('Share a summary with others'),
                  onTap: () {
                    Navigator.pop(context);
                    _shareStatistics();
                  },
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _exportAsPdf() async {
    final accidentsData = await ref.read(streamAccidentProvider.future);
    final filteredAccidents = _filterAccidents(accidentsData);

    // Count by region for summary
    final regionCounts = <String, int>{};
    for (var accident in filteredAccidents) {
      regionCounts[accident.region] = (regionCounts[accident.region] ?? 0) + 1;
    }

    // Generate title based on filters
    String title = 'Accident Statistics';
    if (_regionFilter != 'All Regions') {
      title += ' - $_regionFilter';
    }
    if (_timeFilter != 'All Time') {
      title += ' ($_timeFilter)';
    }

    // Use the ReportGenerator to create and share PDF
    final reportGenerator = ReportGenerator();
    await reportGenerator.generatePdfReport(
      filteredAccidents,
      regionCounts,
      title,
    );
  }

  Future<void> _exportAsCsv() async {
    final accidentsData = await ref.read(streamAccidentProvider.future);
    final filteredAccidents = _filterAccidents(accidentsData);

    // Generate filename based on filters
    String fileName = 'accident_statistics';
    if (_regionFilter != 'All Regions') {
      fileName += '_${_regionFilter.toLowerCase().replaceAll(' ', '_')}';
    }

    // Use the ReportGenerator to create CSV
    final reportGenerator = ReportGenerator();
    final file = await reportGenerator.generateCsvReport(
      filteredAccidents,
      fileName,
    );

    // Share the file
    await Share.shareXFiles([
      XFile(file.path),
    ], text: 'Accident Statistics Data');
  }

  Future<void> _shareStatistics() async {
    final accidentsData = await ref.read(streamAccidentProvider.future);
    final filteredAccidents = _filterAccidents(accidentsData);

    // Create a simple text summary
    final totalAccidents = filteredAccidents.length;
    final fatalAccidents =
        filteredAccidents.where((a) => a.effects == 'Fatal').length;
    final injuryAccidents =
        filteredAccidents.where((a) => a.effects == 'Injury').length;

    final summary = '''
Road Accident Statistics Summary
--------------------------------
Time Period: $_timeFilter
Region: $_regionFilter
Total Accidents: $totalAccidents
Fatal Accidents: $fatalAccidents
Injury Accidents: $injuryAccidents
    ''';

    await SharePlus.instance.share(
      ShareParams(text: summary, subject: 'Road Accident Statistics'),
    );
  }

  Widget _buildSeverityByRegionChart(List<Accident> accidents) {
    // Group accidents by region and severity
    final regionSeverityData = <String, Map<String, int>>{};

    for (var accident in accidents) {
      if (!regionSeverityData.containsKey(accident.region)) {
        regionSeverityData[accident.region] = {};
      }
      regionSeverityData[accident.region]![accident.effects] =
          (regionSeverityData[accident.region]![accident.effects] ?? 0) + 1;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Severity by Region Analysis',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  groupsSpace: 12,
                  barGroups: _getRegionSeverityBarGroups(regionSeverityData),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 &&
                              value.toInt() < regionSeverityData.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                regionSeverityData.keys.elementAt(
                                  value.toInt(),
                                ),
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    drawHorizontalLine: true,
                    horizontalInterval: 5,
                    getDrawingHorizontalLine:
                        (value) =>
                            FlLine(color: Colors.grey[300]!, strokeWidth: 1),
                  ),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildSeverityLegend(),
          ],
        ),
      ),
    );
  }

  List<BarChartGroupData> _getRegionSeverityBarGroups(
    Map<String, Map<String, int>> regionSeverityData,
  ) {
    final effectsList = [
      'Fatal',
      'Serious Injury',
      'Minor Injury',
      'Property Damage',
    ];
    final barGroups = <BarChartGroupData>[];

    int index = 0;
    regionSeverityData.forEach((region, severities) {
      final barRods = <BarChartRodData>[];

      for (int i = 0; i < effectsList.length; i++) {
        final effect = effectsList[i];
        final count = severities[effect] ?? 0;

        barRods.add(
          BarChartRodData(
            toY: count.toDouble(),
            color: _getSeverityColor(effect),
            width: 16,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        );
      }

      barGroups.add(
        BarChartGroupData(x: index, barRods: barRods, groupVertically: true),
      );

      index++;
    });

    return barGroups;
  }

  Widget _buildSeverityLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem('Fatal', "0", Colors.red[700]!),
        const SizedBox(width: 16),
        _buildLegendItem('Serious Injury', "0", Colors.orange[700]!),
        const SizedBox(width: 16),
        _buildLegendItem('Minor Injury', "0", Colors.yellow[700]!),
        const SizedBox(width: 16),
        _buildLegendItem('Property Damage', "0", Colors.blue[700]!),
      ],
    );
  }

  Widget _buildRegionalComparisonChart(List<Accident> accidents) {
    // Group accidents by region
    final regionData = <String, int>{};
    for (var accident in accidents) {
      regionData[accident.region] = (regionData[accident.region] ?? 0) + 1;
    }

    // Sort regions by accident count (descending)
    final sortedRegions =
        regionData.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    // Take top 5 regions for better visualization
    final topRegions = sortedRegions.take(5).toList();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Regional Accident Distribution',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY:
                      topRegions.isEmpty
                          ? 10
                          : (topRegions.first.value * 1.2).toDouble(),
                  barGroups: List.generate(
                    topRegions.length,
                    (index) => BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: topRegions[index].value.toDouble(),
                          color: Theme.of(context).primaryColor,
                          width: 20,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 &&
                              value.toInt() < topRegions.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                topRegions[value.toInt()].key,
                                style: const TextStyle(fontSize: 10),
                                textAlign: TextAlign.center,
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    drawHorizontalLine: true,
                    horizontalInterval: 10,
                    getDrawingHorizontalLine:
                        (value) =>
                            FlLine(color: Colors.grey[300]!, strokeWidth: 1),
                  ),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (regionData.length > 5)
              Text(
                'Note: Showing top 5 regions with highest accident counts',
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContributingFactorsChart(List<Accident> accidents) {
    // Group accidents by contributing factors
    final factorData = <String, int>{};
    for (var accident in accidents) {
      if (accident.environmentalFactors.isNotEmpty) {
        factorData[accident.environmentalFactors] =
            (factorData[accident.environmentalFactors] ?? 0) + 1;
      }
    }

    // Handle empty data
    if (factorData.isEmpty) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Text(
              'No contributing factors data available',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contributing Factors Analysis',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY:
                      factorData.values
                          .fold(0, (max, value) => value > max ? value : max)
                          .toDouble(),
                  barGroups:
                      factorData.entries.map((entry) {
                        return BarChartGroupData(
                          x: factorData.keys.toList().indexOf(entry.key),
                          barRods: [
                            BarChartRodData(
                              toY: entry.value.toDouble(),
                              color: Theme.of(context).primaryColor,
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
                              value.toInt() < factorData.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                factorData.keys.elementAt(value.toInt()),
                                style: const TextStyle(fontSize: 10),
                                textAlign: TextAlign.center,
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    drawHorizontalLine: true,
                    horizontalInterval: 5,
                    getDrawingHorizontalLine:
                        (value) =>
                            FlLine(color: Colors.grey[300]!, strokeWidth: 1),
                  ),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleTypesChart(List<Accident> accidents) {
    final vehicleData = <String, int>{};
    for (var accident in accidents) {
      // Extract vehicle types from involved parties
      for (var party in accident.involvedParties) {
        if (party.type.toLowerCase().contains('vehicle')) {
          vehicleData[party.details] = (vehicleData[party.details] ?? 0) + 1;
        }
      }
    }

    return _buildPieChartWithLegend(vehicleData, [
      Colors.blue[700]!,
      Colors.red[700]!,
      Colors.green[700]!,
      Colors.orange[700]!,
      Colors.purple[700]!,
      Colors.teal[700]!,
    ], 'Vehicle Types Involved');
  }

  Widget _buildRoadConditionsChart(List<Accident> accidents) {
    final roadConditionData = <String, int>{};
    for (var accident in accidents) {
      roadConditionData[accident.environmentalFactors] =
          (roadConditionData[accident.environmentalFactors] ?? 0) + 1;
    }

    return _buildPieChartWithLegend(roadConditionData, [
      Colors.blue[700]!,
      Colors.red[700]!,
      Colors.green[700]!,
      Colors.orange[700]!,
      Colors.purple[700]!,
      Colors.teal[700]!,
    ], 'Road Conditions Analysis');
  }

  Widget _buildWeatherImpactChart(List<Accident> accidents) {
    final weatherData = <String, int>{};
    for (var accident in accidents) {
      weatherData[accident.weather] = (weatherData[accident.weather] ?? 0) + 1;
    }

    return _buildPieChartWithLegend(weatherData, [
      Colors.blue[700]!,
      Colors.red[700]!,
      Colors.green[700]!,
      Colors.orange[700]!,
      Colors.purple[700]!,
      Colors.teal[700]!,
    ], 'Weather Impact Analysis');
  }

  Future<void> _showDateRangePicker() async {
    final DateTimeRange? dateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange:
          _startDate != null && _endDate != null
              ? DateTimeRange(start: _startDate!, end: _endDate!)
              : null,
    );
    if (dateRange != null) {
      setState(() {
        _startDate = dateRange.start;
        _endDate = dateRange.end;
      });
    }
  }
}
