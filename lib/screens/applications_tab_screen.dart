import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../data/applications_data.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/application_service.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'package:intl/intl.dart';

class ApplicationsTabScreen extends StatefulWidget {
  final VoidCallback onBackToHome;
  final bool isAdmin;
  const ApplicationsTabScreen({
    super.key,
    required this.onBackToHome,
    this.isAdmin = false,
  });

  @override
  State<ApplicationsTabScreen> createState() => _ApplicationsTabScreenState();
}

class _ApplicationsTabScreenState extends State<ApplicationsTabScreen> {
  final NotificationService _notificationService = NotificationService();

  // Use shared applications data
  // List<Map<String, dynamic>> get applications => globalApplications;
  List<Map<String, dynamic>> applications = [];
  static var userId = "";
  // Filter options
  String selectedFilter = 'All';
  List<String> filterOptions = [
    'All',
    'Selected',
    'Rejected',
    'Joined',
    'Pending',
  ];

  List<Map<String, dynamic>> get filteredApplications {
    if (selectedFilter == 'All') {
      return applications;
    }
    return applications.where((app) {
      return (app['callStatus'] ?? '').toString().toLowerCase() ==
          selectedFilter.toLowerCase();
    }).toList();
  }

  // Selection state for download
  Set<int> selectedApplicationIndexes = {};
  bool isSelectingForDownload = false;

  @override
  void initState() {
    super.initState();
    userId =
        Provider.of<UserProvider>(context, listen: false).userId?.toString() ??
        '';
    _loadApplication();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Navigate to home tab (adjust route name if needed)
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        return false;
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Theme.of(context).iconTheme.color,
            ),
            onPressed: widget.onBackToHome,
          ),
          title: Text(
            'Application',
            style: Theme.of(context).appBarTheme.titleTextStyle,
          ),
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          elevation: 1,
          actions: [
            IconButton(
              icon: Icon(Icons.download),
              tooltip: 'Download CSV',
              onPressed: () async {
                try {
                  await ReachedCandidateService.downloadReachedCandidatesCSV(
                    userId,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('CSV downloaded successfully.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Download failed: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
            if (isSelectingForDownload)
              IconButton(
                icon: Icon(
                  selectedApplicationIndexes.length ==
                              filteredApplications.length &&
                          filteredApplications.isNotEmpty
                      ? Icons.check_box
                      : Icons.check_box_outline_blank,
                  color: Theme.of(context).iconTheme.color,
                ),
                tooltip:
                    selectedApplicationIndexes.length ==
                            filteredApplications.length &&
                        filteredApplications.isNotEmpty
                    ? 'Deselect All'
                    : 'Select All',
                onPressed: () {
                  setState(() {
                    if (selectedApplicationIndexes.length ==
                            filteredApplications.length &&
                        filteredApplications.isNotEmpty) {
                      selectedApplicationIndexes.clear();
                    } else {
                      selectedApplicationIndexes = filteredApplications
                          .map((c) => applications.indexOf(c))
                          .toSet();
                    }
                  });
                },
              ),
            // Filter dropdown
            PopupMenuButton<String>(
              icon: Icon(
                Icons.filter_list,
                color: Theme.of(context).iconTheme.color,
              ),
              onSelected: (String value) {
                setState(() {
                  selectedFilter = value;
                });
              },
              itemBuilder: (BuildContext context) => filterOptions.map((
                String choice,
              ) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Row(
                    children: [
                      if (selectedFilter == choice)
                        Icon(
                          Icons.check,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                      if (selectedFilter == choice) const SizedBox(width: 8),
                      Text(choice),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        body: Column(
          children: [
            // Filter status bar
            if (selectedFilter != 'All')
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                child: Row(
                  children: [
                    Icon(
                      Icons.filter_alt,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Showing $selectedFilter applications (${filteredApplications.length})',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedFilter = 'All';
                        });
                      },
                      child: Text(
                        'Clear',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            // Applications list
            Expanded(
              child: filteredApplications.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.article_outlined,
                            size: 80,
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.color?.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            selectedFilter == 'All'
                                ? 'No applications yet'
                                : 'No $selectedFilter applications',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.color,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Applications will appear here when candidates apply',
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredApplications.length,
                      itemBuilder: (context, index) {
                        final appIndex = applications.indexOf(
                          filteredApplications[index],
                        );
                        return _buildApplicationCard(
                          filteredApplications[index],
                          appIndex,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicationCard(Map<String, dynamic> application, int index) {
    Color getStatusColor(String status) {
      switch (status) {
        case 'Selected':
          return Colors.blue;
        case 'Rejected':
          return Colors.red;
        case 'Joined':
          return Colors.green;
        default:
          return Colors.orange;
      }
    }

    String getStatusText(String status) {
      switch (status) {
        case 'selected':
          return 'Selected';
        case 'rejected':
          return 'Rejected';
        case 'joined':
          return 'Joined';
        default:
          return 'Pending';
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: getStatusColor(
              (application['callStatus'] ?? '')
                  .toString()
                  .toLowerCase()
                  .replaceFirstMapped(
                    RegExp(r'^.'),
                    (match) => match.group(0)!.toUpperCase(),
                  ),
            ).withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            // Header with company info and avatar
            Row(
              children: [
                if (isSelectingForDownload)
                  Checkbox(
                    value: selectedApplicationIndexes.contains(index),
                    onChanged: (checked) {
                      setState(() {
                        if (checked == true) {
                          selectedApplicationIndexes.add(index);
                        } else {
                          selectedApplicationIndexes.remove(index);
                        }
                      });
                    },
                  ),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onLongPress: () {
                      if (!isSelectingForDownload) {
                        setState(() {
                          isSelectingForDownload = true;
                          selectedApplicationIndexes.add(index);
                        });
                      }
                    },
                    child: AbsorbPointer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${application['candidateName'] ?? ''}',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${application['companyName'] ?? ''}',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${application['role'] ?? ''}',
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formatDate(application['addedDateTime']),
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Avatar
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0E68C), // Light yellow background
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${(application['candidateName'] ?? '').toString().isNotEmpty ? (application['candidateName'] as String)[0].toUpperCase() : ''}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Status badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: getStatusColor(
                      application['status'] ?? '',
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: getStatusColor(
                        (application['callStatus'] ?? '')
                            .toString()
                            .toLowerCase()
                            .replaceFirstMapped(
                              RegExp(r'^.'),
                              (match) => match.group(0)!.toUpperCase(),
                            ),
                      ),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    (application['callStatus'] ?? '')
                        .toString()
                        .toLowerCase()
                        .replaceFirstMapped(
                          RegExp(r'^.'),
                          (match) => match.group(0)!.toUpperCase(),
                        ),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: getStatusColor(
                        (application['callStatus'] ?? '')
                            .toString()
                            .toLowerCase()
                            .replaceFirstMapped(
                              RegExp(r'^.'),
                              (match) => match.group(0)!.toUpperCase(),
                            ),
                      ),
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 16),
            // Action buttons
            Row(
              children: [
                // WhatsApp button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _openWhatsApp(application['phone'] ?? ''),
                    icon: const FaIcon(
                      FontAwesomeIcons.whatsapp,
                      size: 18,
                      color: Color(0xFF319582),
                    ),
                    label: const Text(''),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD1EFEA),
                      foregroundColor: Color(0xFF319582),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Phone button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _makePhoneCall(application['phone'] ?? ''),
                    icon: const Icon(
                      Icons.phone,
                      size: 18,
                      color: Color(0xFF414789),
                    ),
                    label: const Text(''),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFBE9B7),
                      foregroundColor: Color(0xFF414789),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // More options (3-dot menu, admin only)
                if (widget.isAdmin)
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: Color(0xFF726E02)),
                    onSelected: (String value) {
                      _handleStatusChange(application, value, index);
                    },
                    itemBuilder: (BuildContext context) => [
                      PopupMenuItem<String>(
                        value: 'selected',
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              color: Colors.blue,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text('Selected'),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'rejected',
                        child: Row(
                          children: [
                            Icon(
                              Icons.cancel_outlined,
                              color: Colors.red,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text('Rejected'),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'joined',
                        child: Row(
                          children: [
                            Icon(
                              Icons.person_add_outlined,
                              color: Colors.green,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text('Joined'),
                          ],
                        ),
                      ),
                    ],
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // WhatsApp functionality
  void _openWhatsApp(String phoneNumber) async {
    // Remove any special characters and spaces
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final whatsappUrl = "https://wa.me/$cleanNumber";

    try {
      final uri = Uri.parse(whatsappUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('WhatsApp is not installed on this device'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to open WhatsApp'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Phone call functionality
  void _makePhoneCall(String phoneNumber) async {
    final phoneUrl = "tel:$phoneNumber";

    try {
      final uri = Uri.parse(phoneUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unable to make phone call'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to make phone call'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Handle status change from dropdown
  void _handleStatusChange(
    Map<String, dynamic> application,
    String newStatus,
    int index,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Update Application Status'),
        content: Text('Mark ${application['candidateName']} as $newStatus?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _performStatusUpdate(application, newStatus);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Selected':
        return Colors.blue;
      case 'Rejected':
        return Colors.red;
      case 'Joined':
        return Colors.green;
      default:
        return Colors.orange;
    }
  }

  // Placeholder for download logic
  Future<void> _downloadSelectedApplications() async {
    // You can implement Excel or CSV export here, similar to candidates_tab_screen.dart
    // For now, just show a message
    if (selectedApplicationIndexes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No applications selected for download'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Downloaded ${selectedApplicationIndexes.length} applications',
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _performStatusUpdate(
    Map<String, dynamic> application,
    String newStatus,
  ) async {
    late BuildContext loaderContext;

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (ctx) {
        loaderContext = ctx;
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      final success = await CandidateTrack.updateStatus(
        application['trackerId'].toString(),
        newStatus.toUpperCase(),
        userId,
      );

      if (!mounted) return;

      Navigator.pop(loaderContext); // Close loader

      if (success) {
        setState(() {
          final idx = applications.indexWhere(
            (app) => app['id'] == application['id'],
          );
          if (idx != -1) applications[idx]['status'] = newStatus;
        });
        _notificationService.addNotification(
          title: 'Status Updated',
          message: '${application['candidateName']} is now $newStatus',
          type: NotificationType.general,
          candidateName: application['candidateName'],
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status changed to $newStatus'),
            backgroundColor: _getStatusColor(newStatus),
          ),
        );
      } else {
        _showErrorSnackbar(context, 'Failed to update. Try again.');
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(loaderContext);
        _showErrorSnackbar(context, 'Error: $e');
      }
    }
  }

  Future<void> _loadApplication() async {
    try {
      final reachedCandidate =
          await ReachedCandidateService.fetchReachedCandidates(userId);
      setState(() {
        applications = reachedCandidate;
      });
    } catch (e) {
      print('Error fetching reached candidates: $e');
    }
  }

  String formatDate(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) return '';

    try {
      final dateTime = DateTime.parse(dateTimeStr);
      return DateFormat('yyyy-MM-dd').format(dateTime); // Output: 2025-07-24
    } catch (e) {
      return ''; // Or handle parsing errors
    }
  }
}
