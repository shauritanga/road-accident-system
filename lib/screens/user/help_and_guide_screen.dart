import 'package:flutter/material.dart';

class HelpAndGuideScreen extends StatefulWidget {
  const HelpAndGuideScreen({super.key});

  @override
  State<HelpAndGuideScreen> createState() => _HelpAndGuideScreenState();
}

class _HelpAndGuideScreenState extends State<HelpAndGuideScreen> {
  int _selectedIndex = 0;

  final List<String> _categories = [
    'Getting Started',
    'Reporting',
    'Maps & Location',
    'Statistics',
    'Account',
    'FAQ',
  ];

  @override
  Widget build(BuildContext context) {
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
        title: const Text('Help & Guide'),
        centerTitle: true,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Column(
        children: [
          // Header with government-style design
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
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.help_outline,
                        color: primaryColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'OFFICIAL USER GUIDE',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Road Accident Reporting System',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Category tabs
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 2,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final isSelected = index == _selectedIndex;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isSelected ? primaryColor : Colors.transparent,
                          width: 3,
                        ),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _categories[index],
                        style: TextStyle(
                          color: isSelected ? primaryColor : Colors.grey[600],
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Content based on selected category
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _buildCategoryContent(_selectedIndex),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryContent(int index) {
    switch (index) {
      case 0:
        return _buildGettingStartedContent();
      case 1:
        return _buildReportingContent();
      case 2:
        return _buildMapsContent();
      case 3:
        return _buildStatisticsContent();
      case 4:
        return _buildAccountContent();
      case 5:
        return _buildFAQContent();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildGettingStartedContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Welcome to the Road Accident Reporting System'),
        const SizedBox(height: 16),
        _buildInfoCard(
          'About This System',
          'The Road Accident Reporting System is an official platform designed to streamline the process of reporting and managing road accidents across the country. This system helps traffic officers collect accurate data, analyze trends, and improve road safety.',
          Icons.info_outline,
        ),
        const SizedBox(height: 20),
        _buildSectionTitle('Key Features'),
        const SizedBox(height: 16),
        _buildFeatureItem(
          'Accident Reporting',
          'Record comprehensive details about road accidents',
          Icons.report_problem_outlined,
        ),
        _buildFeatureItem(
          'Location Mapping',
          'Pinpoint exact accident locations using GPS',
          Icons.location_on_outlined,
        ),
        _buildFeatureItem(
          'Statistical Analysis',
          'View trends and patterns in accident data',
          Icons.bar_chart_outlined,
        ),
        _buildFeatureItem(
          'Report Generation',
          'Create and export official accident reports',
          Icons.description_outlined,
        ),
        const SizedBox(height: 20),
        _buildSectionTitle('Getting Started'),
        const SizedBox(height: 16),
        _buildStepItem(
          '1',
          'Login with your official credentials',
          'Use your government-issued email and password to access the system.',
        ),
        _buildStepItem(
          '2',
          'Explore the dashboard',
          'Familiarize yourself with the main sections and navigation.',
        ),
        _buildStepItem(
          '3',
          'Report your first accident',
          'Tap the "Report Accident" button to begin recording an incident.',
        ),
      ],
    );
  }

  Widget _buildReportingContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Accident Reporting Guide'),
        const SizedBox(height: 16),
        _buildInfoCard(
          'Reporting Process',
          'The accident reporting process is designed to be thorough yet efficient. Follow these steps to ensure all necessary information is captured accurately.',
          Icons.assignment_outlined,
        ),
        const SizedBox(height: 20),
        _buildSectionTitle('Step-by-Step Reporting'),
        const SizedBox(height: 16),
        _buildStepItem(
          '1',
          'Initiate a new report',
          'From the dashboard, tap the "Report Accident" button to start a new report.',
        ),
        _buildStepItem(
          '2',
          'Record location details',
          'Use the map to pinpoint the exact accident location. The system will automatically capture GPS coordinates and suggest the nearest road name.',
        ),
        _buildStepItem(
          '3',
          'Enter accident information',
          'Select the accident type, severity, weather conditions, and other relevant factors from the dropdown menus.',
        ),
        _buildStepItem(
          '4',
          'Document the scene',
          'Take photos of the accident scene using the built-in camera feature. These will be attached to your report.',
        ),
        _buildStepItem(
          '5',
          'Add involved parties',
          'Record details of all vehicles, drivers, and other parties involved in the accident.',
        ),
        _buildStepItem(
          '6',
          'Submit the report',
          'Review all information for accuracy, then submit the report to the central database.',
        ),
        const SizedBox(height: 20),
        _buildSectionTitle('Important Tips'),
        const SizedBox(height: 16),
        _buildTipItem(
          'Be precise with location',
          'Accurate location data is crucial for analysis and future road safety improvements.',
        ),
        _buildTipItem(
          'Document thoroughly',
          'Include multiple photos from different angles to provide a complete view of the accident scene.',
        ),
        _buildTipItem(
          'Note environmental factors',
          'Record all relevant conditions such as road surface, visibility, and weather that may have contributed to the accident.',
        ),
      ],
    );
  }

  Widget _buildMapsContent() {
    // Content for Maps & Location section
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Using Maps & Location Features'),
        const SizedBox(height: 16),
        _buildInfoCard(
          'Location Tracking',
          'The system uses GPS technology to accurately record accident locations. This data is crucial for identifying high-risk areas and implementing targeted safety measures.',
          Icons.map_outlined,
        ),
        const SizedBox(height: 20),
        _buildSectionTitle('Map Navigation'),
        const SizedBox(height: 16),
        _buildFeatureItem(
          'Accident Hotspots',
          'Red clusters indicate areas with high accident frequencies',
          Icons.local_fire_department_outlined,
        ),
        _buildFeatureItem(
          'Filtering Options',
          'Filter accidents by type, date range, or severity',
          Icons.filter_list_outlined,
        ),
        _buildFeatureItem(
          'Detailed View',
          'Tap on any marker to view complete accident details',
          Icons.zoom_in_outlined,
        ),
        _buildFeatureItem(
          'Current Location',
          'Use the location button to center the map on your position',
          Icons.my_location_outlined,
        ),
        const SizedBox(height: 20),
        _buildSectionTitle('Recording Accident Locations'),
        const SizedBox(height: 16),
        _buildStepItem(
          '1',
          'Enable location services',
          'Ensure your device\'s GPS is active for accurate positioning.',
        ),
        _buildStepItem(
          '2',
          'Mark the exact spot',
          'Position the pin precisely at the accident location or tap "Use My Location" if you\'re at the scene.',
        ),
        _buildStepItem(
          '3',
          'Verify address details',
          'Confirm the suggested road name, area, and other location information.',
        ),
        _buildStepItem(
          '4',
          'Add multiple points (if needed)',
          'For accidents covering larger areas, you can add additional points to mark the extent.',
        ),
      ],
    );
  }

  Widget _buildStatisticsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Understanding Statistics & Analytics'),
        const SizedBox(height: 16),
        _buildInfoCard(
          'Data-Driven Insights',
          'The statistics section provides valuable insights into accident patterns and trends, helping authorities make informed decisions about road safety measures.',
          Icons.insights_outlined,
        ),
        const SizedBox(height: 20),
        _buildSectionTitle('Available Charts & Reports'),
        const SizedBox(height: 16),
        _buildFeatureItem(
          'Accident Trends',
          'View how accident rates change over time',
          Icons.trending_up_outlined,
        ),
        _buildFeatureItem(
          'Accident Types',
          'Breakdown of accidents by category',
          Icons.pie_chart_outline,
        ),
        _buildFeatureItem(
          'Severity Analysis',
          'Distribution of accidents by severity level',
          Icons.warning_amber_outlined,
        ),
        _buildFeatureItem(
          'Time of Day Analysis',
          'Identify peak hours for accidents',
          Icons.access_time_outlined,
        ),
        const SizedBox(height: 20),
        _buildSectionTitle('Using Filters'),
        const SizedBox(height: 16),
        _buildStepItem(
          '1',
          'Select time period',
          'Choose from preset time ranges or set a custom date range.',
        ),
        _buildStepItem(
          '2',
          'Filter by region',
          'Focus on specific geographic areas to analyze local patterns.',
        ),
        _buildStepItem(
          '3',
          'Apply additional filters',
          'Refine data by accident type, road conditions, or other factors.',
        ),
        _buildStepItem(
          '4',
          'Export reports',
          'Generate PDF or CSV reports for official use or further analysis.',
        ),
      ],
    );
  }

  Widget _buildAccountContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Managing Your Account'),
        const SizedBox(height: 16),
        _buildInfoCard(
          'Account Security',
          "Your account provides secure access to the Road Accident Reporting System. It's important to maintain proper security practices to protect sensitive data.",
          Icons.security_outlined,
        ),
        const SizedBox(height: 20),
        _buildSectionTitle('Account Features'),
        const SizedBox(height: 16),
        _buildFeatureItem(
          'Profile Management',
          'View and update your personal information',
          Icons.person_outline,
        ),
        _buildFeatureItem(
          'Activity History',
          'Track your reporting activity and submissions',
          Icons.history_outlined,
        ),
        _buildFeatureItem(
          'Notification Settings',
          'Manage system alerts and reminders',
          Icons.notifications_outlined,
        ),
        _buildFeatureItem(
          'Security Settings',
          'Change password and security preferences',
          Icons.lock_outline,
        ),
        const SizedBox(height: 20),
        _buildSectionTitle('Best Practices'),
        const SizedBox(height: 16),
        _buildTipItem(
          'Regular password updates',
          'Change your password periodically to maintain account security.',
        ),
        _buildTipItem(
          'Secure logout',
          'Always log out when you\'re finished, especially on shared devices.',
        ),
        _buildTipItem(
          'Verify your reports',
          'Regularly check your submission history to ensure all reports are accurate.',
        ),
      ],
    );
  }

  Widget _buildFAQContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Frequently Asked Questions'),
        const SizedBox(height: 16),
        _buildFaqItem(
          'What should I do if I lose internet connection while reporting?',
          'The system automatically saves your report as a draft. Once you regain connection, you can continue from where you left off and submit the report.',
        ),
        _buildFaqItem(
          'Can I edit a report after submission?',
          'Once submitted, reports cannot be directly edited to maintain data integrity. However, you can contact your supervisor to request corrections if necessary.',
        ),
        _buildFaqItem(
          'How do I attach multiple photos to a report?',
          'When creating a report, tap the "Add Photos" button multiple times to capture and attach several images. You can preview and delete photos before submission.',
        ),
        _buildFaqItem(
          'Is the location data accurate in rural areas?',
          'GPS accuracy may vary in remote locations. In areas with poor GPS signal, you can manually adjust the pin location on the map or enter coordinates if known.',
        ),
        _buildFaqItem(
          'How can I generate custom reports for my jurisdiction?',
          'In the Statistics section, apply filters for your specific region and time period, then use the "Export" button to generate a custom report in PDF or CSV format.',
        ),
        _buildFaqItem(
          'What should I do if I forget my password?',
          'On the login screen, tap "Forgot Password" and follow the instructions. A password reset link will be sent to your registered email address.',
        ),
        _buildFaqItem(
          'Can I use the app offline?',
          'Limited offline functionality is available. You can create draft reports offline, but internet connection is required to submit them to the central database.',
        ),
        _buildFaqItem(
          'How do I report technical issues with the system?',
          'Tap on your profile icon, select "Help & Support," then "Report an Issue." Provide details about the problem you\'re experiencing for technical assistance.',
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.grey[800],
      ),
    );
  }

  Widget _buildInfoCard(String title, String content, IconData icon) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Theme.of(context).primaryColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(String number, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.lightbulb_outlined,
              color: Theme.of(context).primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(answer, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
        ],
      ),
    );
  }
}
