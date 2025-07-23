import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../services/notification_service.dart';
import '../../data/candidates_data.dart' as candidates_data;
import '../widgets/candidate_popup_form.dart';
import '../widgets/edit_candidate_popup.dart';
import '../../data/user_role.dart';
import 'package:excel/excel.dart' as excel;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/Candidate_model.dart';
import '../services/candidate_service.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class CandidatesTabScreen extends StatefulWidget {
  final VoidCallback onBackToHome;
  final bool isAdmin;
  const CandidatesTabScreen({
    super.key,
    required this.onBackToHome,
    this.isAdmin = false,
  });

  @override
  State<CandidatesTabScreen> createState() => _CandidatesTabScreenState();
}

class _CandidatesTabScreenState extends State<CandidatesTabScreen> {
  final NotificationService _notificationService = NotificationService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  // Search variables
  String _searchQuery = '';
  bool _isSearching = false;
  List<Map<String, dynamic>> filteredCandidates = [];

  // Selection state for download
  Set<int> selectedCandidateIndexes = {};
  bool isSelectingForDownload = false;

  // Light button colors
  static const Color lightGreen = Color(0xFFD1EFEA); // Interview
  static const Color lightOrange = Color(0xFFFBE9B7); // Reschedule
  static const Color lightRed = Color(0xFFFFE8E8); // Reached (finalized)

  // Button text colors
  static const Color interviewTextColor = Color(0xFF319582);
  static const Color rescheduleTextColor = Color(0xFF726E02);
  static const Color reachedTextColor = Color(0xFFFF3535);

  // All candidates data with additional fields for popup
  // Use the global candidates list
  // List<Map<String, dynamic>> get allCandidates =>
  //     candidates_data.globalCandidates;

  late List<Map<String, dynamic>> allCandidates = [];
  static var userId = "";

  @override
  void initState() {
    super.initState();
    // get data from api
    // fetchCandidates();
    userId =
        Provider.of<UserProvider>(context, listen: false).userId?.toString() ??
        '';
    loadCandidates();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _filterCandidates(_searchQuery);
    });
  }

  void _filterCandidates(String query) {
    if (query.isEmpty) {
      filteredCandidates = allCandidates;
      _isSearching = false;
    } else {
      _isSearching = true;
      filteredCandidates = allCandidates.where((candidate) {
        final name = (candidate['name'] ?? '').toString();
        final role = (candidate['role'] ?? '').toString();
        final location = (candidate['location'] ?? '').toString();
        final qualification = (candidate['qualification'] ?? '').toString();
        final experience = (candidate['experience'] ?? '').toString();
        return name.toLowerCase().contains(query.toLowerCase()) ||
            role.toLowerCase().contains(query.toLowerCase()) ||
            location.toLowerCase().contains(query.toLowerCase()) ||
            qualification.toLowerCase().contains(query.toLowerCase()) ||
            experience.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _isSearching = false;
      filteredCandidates = allCandidates;
    });
  }

  // Show candidate details popup
  void _showCandidateDetails(Map<String, dynamic> candidate, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Theme.of(context).cardColor,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            padding: const EdgeInsets.all(24),
            color: Theme.of(context).cardColor,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with name and 3-dot menu
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (candidate['name'] ?? '').toString(),
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'ID: ${(candidate['id'] ?? '').toString()}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            (candidate['role'] ?? '').toString(),
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: textSecondary),
                      onSelected: (String value) {
                        if (value == 'remove') {
                          final allIndex = allCandidates.indexOf(candidate);
                          _removeCandidate(allIndex);
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        if (widget.isAdmin)
                          const PopupMenuItem<String>(
                            value: 'remove',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text('Remove Candidate'),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Rating and View Resume
                Row(
                  children: [
                    // Rating stars (interactive)
                    Row(
                      children: [
                        Text(
                          (candidate['rating'] ?? '').toString(),
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          children: List.generate(5, (starIndex) {
                            if (widget.isAdmin) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pop();
                                  setState(() {
                                    allCandidates[index]['rating'] =
                                        starIndex + 1.0;
                                    _filterCandidates(_searchQuery);
                                  });
                                  // Reopen the dialog to reflect the new rating
                                  Future.delayed(
                                    const Duration(milliseconds: 200),
                                    () {
                                      _showCandidateDetails(
                                        allCandidates[index],
                                        index,
                                      );
                                    },
                                  );
                                },
                                child: Icon(
                                  starIndex < (candidate['rating'] ?? 0).floor()
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: Colors.amber,
                                  size: 24,
                                ),
                              );
                            } else {
                              return Icon(
                                starIndex < (candidate['rating'] ?? 0).floor()
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.amber,
                                size: 24,
                              );
                            }
                          }),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // View Resume button
                    ElevatedButton(
                      onPressed: () {
                        print(
                          'View Resume for ${(candidate['name'] ?? '').toString()}',
                        );
                        // TODO: Implement view resume functionality
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE3F2FD),
                        foregroundColor: primaryBlue,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        'View Resume',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Theme.of(context).colorScheme.primary
                              : primaryBlue,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Details grid
                Row(
                  children: [
                    Expanded(
                      child: _buildPopupDetailItem(
                        'Job Title',
                        (candidate['role'] ?? '').toString(),
                      ),
                    ),
                    Expanded(
                      child: _buildPopupDetailItem(
                        'Experience',
                        (candidate['experience'] ?? '').toString(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildPopupDetailItem(
                        'Name',
                        (candidate['name'] ?? '').toString(),
                      ),
                    ),
                    Expanded(
                      child: _buildPopupDetailItem(
                        'Age',
                        (candidate['age'] ?? '').toString(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildPopupDetailItem(
                        'Location',
                        (candidate['location'] ?? '').toString(),
                      ),
                    ),
                    Expanded(
                      child: _buildPopupDetailItem(
                        'Qualification',
                        (candidate['qualification'] ?? '').toString(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Notes section (editable)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Notes',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                StatefulBuilder(
                  builder: (context, setStateDialog) {
                    final TextEditingController notesController =
                        TextEditingController(text: candidate['notes'] ?? '');
                    return Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Theme.of(
                                    context,
                                  ).colorScheme.surface.withOpacity(0.7)
                                : const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Theme.of(context).dividerColor,
                            ), // BoxDecoration border OK
                          ),
                          child: TextField(
                            controller: notesController,
                            maxLines: 4,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Write notes here...',
                            ),
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontSize: 14, height: 1.4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              // Save notes
                              setState(() {
                                allCandidates[index]['notes'] =
                                    notesController.text;
                                _filterCandidates(_searchQuery);
                              });
                              // Reopen the dialog to reflect the new notes
                              Future.delayed(
                                const Duration(milliseconds: 200),
                                () {
                                  _showCandidateDetails(
                                    allCandidates[index],
                                    index,
                                  );
                                },
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryBlue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Save Notes',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                // Action buttons: Only Reschedule for user
                const SizedBox(height: 24),
                // Close button
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'Close',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPopupDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // Remove candidate function
  void _removeCandidate(int index) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Remove Candidate'),
          content: Text(
            'Are you sure you want to remove ${(allCandidates[index]['name'] ?? '').toString()} from the candidates list?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  final removedCandidate = allCandidates[index];
                  allCandidates.removeAt(index);
                  _filterCandidates(_searchQuery);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${(removedCandidate['name'] ?? '').toString()} has been removed',
                      ),
                      backgroundColor: Colors.red,
                      action: SnackBarAction(
                        label: 'Undo',
                        textColor: Colors.white,
                        onPressed: () {
                          setState(() {
                            allCandidates.insert(index, removedCandidate);
                            _filterCandidates(_searchQuery);
                          });
                        },
                      ),
                    ),
                  );
                });
                Navigator.of(dialogContext).pop(); // Close confirmation dialog
                Navigator.of(
                  dialogContext,
                ).pop(); // Close candidate details dialog
              },
              child: const Text('Remove', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // Refresh candidates
  Future<void> _refreshCandidates() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      filteredCandidates = allCandidates;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Candidates list refreshed'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Show filter dialog
  void _showFilterDialog(BuildContext context) {
    TextEditingController ageController = TextEditingController();
    TextEditingController roleController = TextEditingController();
    TextEditingController locationController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Filter Candidates'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Age',
                  hintText: 'Enter age',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: roleController,
                decoration: const InputDecoration(
                  labelText: 'Role',
                  hintText: 'Enter role',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  hintText: 'Enter location',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                String age = ageController.text.trim();
                String role = roleController.text.trim().toLowerCase();
                String location = locationController.text.trim().toLowerCase();
                setState(() {
                  filteredCandidates = allCandidates.where((candidate) {
                    bool matches = true;
                    if (age.isNotEmpty) {
                      matches =
                          matches && (candidate['age'] ?? '').toString() == age;
                    }
                    if (role.isNotEmpty) {
                      matches =
                          matches &&
                          (candidate['role'] ?? '')
                              .toString()
                              .toLowerCase()
                              .contains(role);
                    }
                    if (location.isNotEmpty) {
                      matches =
                          matches &&
                          (candidate['location'] ?? '')
                              .toString()
                              .toLowerCase()
                              .contains(location);
                    }
                    return matches;
                  }).toList();
                  _isSearching = true;
                  _searchQuery = '';
                });
                Navigator.pop(context);
              },
              child: const Text('Apply Filters'),
            ),
          ],
        );
      },
    );
  }

  // Add new candidate
  void _addNewCandidate() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.9,
            ),
            child: CandidatePopupForm(
              initialPhone: '',
              initialName: '',
              initialRole: '',
              initialLocation: '',
              initialQualification: '',
              initialExperience: '',
              initialInterviewTime: '',
              onlyEditTime: false,
              userId: userId,
              onBookInterview: (candidateData) {
                Navigator.pop(context);
                setState(() {
                  final newCandidate = Map<String, dynamic>.from(candidateData);
                  newCandidate['id'] = DateTime.now().millisecondsSinceEpoch;
                  if (!newCandidate.containsKey('interviewTime') ||
                      newCandidate['interviewTime'] == null) {
                    newCandidate['interviewTime'] = '';
                  }
                  candidates_data.globalCandidates.insert(0, newCandidate);
                  filteredCandidates = candidates_data.globalCandidates;
                  if (_searchQuery.isNotEmpty) {
                    _filterCandidates(_searchQuery);
                  }
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Candidate added successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  // Edit candidate
  // void _editCandidate(int index) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return EditCandidatePopup(
  //         candidate: allCandidates[index],
  //         onSave: (updatedCandidate) {
  //           setState(() {
  //             allCandidates[index] = updatedCandidate;
  //             _filterCandidates(_searchQuery);
  //           });
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             const SnackBar(
  //               content: Text('Candidate details updated'),
  //               backgroundColor: Colors.green,
  //             ),
  //           );
  //         },
  //       );
  //     },
  //   );
  // }

  void _editCandidate(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditCandidatePopup(
          candidate: allCandidates[index],
          onSave: (updatedCandidate) async {
            final candidateService = CandidateService();

            bool success = await candidateService.updateCandidate(
              updatedCandidate,
              userId,
            );

            if (success) {
              setState(() {
                allCandidates[index] = updatedCandidate;
                _filterCandidates(_searchQuery);
              });

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Candidate details updated successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Failed to update candidate'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        );
      },
    );
  }

  // Go for interview
  void _goForInterview(int index) {
    final parentContext = context;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm GFI Selection'),
          content: Text(
            'Mark ${(allCandidates[index]['name'] ?? '').toString()} as selected for GFI?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);

                final success = await goForInterviewSubmit(
                  allCandidates[index]['id'].toString(),
                );

                if (success) {
                  setState(() {
                    allCandidates[index]['gfiSelected'] = true;
                  });
                  _notificationService.addNotification(
                    title: 'Interview Scheduled',
                    message:
                        'Interview scheduled with ${(allCandidates[index]['name'] ?? '').toString()}',
                    type: NotificationType.interview,
                    candidateName: (allCandidates[index]['name'] ?? '')
                        .toString(),
                  );
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Interview scheduled with ${(allCandidates[index]['name'] ?? '').toString()}',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Failed to schedule interview. Please try again.',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  // Reschedule interview
  void _reschedule(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reschedule Interview'),
          content: Text(
            'Reschedule interview with ${(allCandidates[index]['name'] ?? '').toString()}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _notificationService.addNotification(
                  title: 'Interview Rescheduled',
                  message:
                      'Interview rescheduled with ${(allCandidates[index]['name'] ?? '').toString()}',
                  type: NotificationType.reschedule,
                  candidateName: (allCandidates[index]['name'] ?? '')
                      .toString(),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Interview rescheduled with ${(allCandidates[index]['name'] ?? '').toString()}',
                    ),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
              child: const Text('Reschedule'),
            ),
          ],
        );
      },
    );
  }

  // Mark as reached with api
  Future<bool> _markReached(int index) async {
    bool isSuccess = false;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Mark as Reached'),
          content: Text(
            'Mark ${(allCandidates[index]['name'] ?? '').toString()} as reached?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context); // close dialog first
                try {
                  bool success = await CandidateService.markCandidateReached(
                    userId,
                    allCandidates[index]['id'],
                  );
                  if (success) {
                    _notificationService.addNotification(
                      title: 'Candidate Reached',
                      message:
                          '${(allCandidates[index]['name'] ?? '')} marked as reached',
                      type: NotificationType.reached,
                      candidateName: (allCandidates[index]['name'] ?? '')
                          .toString(),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${(allCandidates[index]['name'] ?? '')} marked as reached',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                    isSuccess = true;
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to mark as reached: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Mark Reached'),
            ),
          ],
        );
      },
    );

    return isSuccess;
  }

  @override
  Widget build(BuildContext context) {
    // load on filler
    filteredCandidates = allCandidates;
    _searchController.addListener(_onSearchChanged);

    return WillPopScope(
      onWillPop: () async {
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
          title: _isSearching
              ? null
              : Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Candidates List',
                        style: Theme.of(context).appBarTheme.titleTextStyle,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${filteredCandidates.length}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          elevation: 1,
          actions: [
            if (!_isSearching) ...[
              IconButton(
                icon: Icon(
                  Icons.search,
                  color: Theme.of(context).iconTheme.color,
                ),
                onPressed: () {
                  setState(() {
                    _isSearching = true;
                  });
                },
              ),
              if (widget.isAdmin) ...[
                IconButton(
                  icon: Icon(
                    Icons.download,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  tooltip: 'Download',
                  onPressed: () async {
                    if (isSelectingForDownload &&
                        selectedCandidateIndexes.isNotEmpty) {
                      await _downloadSelectedCandidates();
                      setState(() {
                        isSelectingForDownload = false;
                        selectedCandidateIndexes.clear();
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Press and hold a candidate name to select candidates for download.',
                          ),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    }
                  },
                ),
                if (isSelectingForDownload)
                  IconButton(
                    icon: Icon(
                      selectedCandidateIndexes.length ==
                                  filteredCandidates.length &&
                              filteredCandidates.isNotEmpty
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      color: Theme.of(context).iconTheme.color,
                    ),
                    tooltip:
                        selectedCandidateIndexes.length ==
                                filteredCandidates.length &&
                            filteredCandidates.isNotEmpty
                        ? 'Deselect All'
                        : 'Select All',
                    onPressed: () {
                      setState(() {
                        if (selectedCandidateIndexes.length ==
                                filteredCandidates.length &&
                            filteredCandidates.isNotEmpty) {
                          selectedCandidateIndexes.clear();
                        } else {
                          selectedCandidateIndexes = filteredCandidates
                              .map((c) => allCandidates.indexOf(c))
                              .toSet();
                        }
                      });
                    },
                  ),
              ],
              IconButton(
                icon: Icon(
                  Icons.filter_list,
                  color: Theme.of(context).iconTheme.color,
                ),
                onPressed: () => _showFilterDialog(context),
              ),
            ] else ...[
              IconButton(
                icon: Icon(
                  Icons.close,
                  color: Theme.of(context).iconTheme.color,
                ),
                onPressed: _clearSearch,
              ),
            ],
          ],
          bottom: _isSearching
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(60),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText:
                            'Search by name, role, location, qualification...',
                        prefixIcon: Icon(
                          Icons.search,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  color: Theme.of(context).iconTheme.color,
                                ),
                                onPressed: _clearSearch,
                              )
                            : null,
                        filled: true,
                        fillColor: Theme.of(context).cardColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                )
              : null,
        ),
        body: RefreshIndicator(
          onRefresh: _refreshCandidates,
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Download button row removed from body
              // Search results header
              if (_isSearching) ...[
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          filteredCandidates.isEmpty
                              ? Icons.search_off
                              : Icons.search,
                          color: textSecondary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            filteredCandidates.isEmpty
                                ? 'No candidates found for "$_searchQuery"'
                                : '${filteredCandidates.length} candidate${filteredCandidates.length == 1 ? '' : 's'} found for "$_searchQuery"',
                            style: const TextStyle(
                              color: textSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              // Candidates list
              if (filteredCandidates.isEmpty && _isSearching) ...[
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_search,
                          size: 80,
                          color: textSecondary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No candidates found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try searching with different keywords',
                          style: TextStyle(
                            fontSize: 14,
                            color: textSecondary.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _clearSearch,
                          icon: const Icon(Icons.clear_all),
                          label: const Text('Clear Search'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                SliverPadding(
                  padding: const EdgeInsets.all(16.0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final reversedList = filteredCandidates.reversed.toList();
                      final candidateIndex = allCandidates.indexOf(
                        reversedList[index],
                      );
                      // Always use the candidate from allCandidates to ensure 'id' is present
                      return _buildCandidateCard(
                        allCandidates[candidateIndex],
                        candidateIndex,
                      );
                    }, childCount: filteredCandidates.length),
                  ),
                ),
                // End of list indicator
                if (!_isSearching)
                  SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: const Center(
                        child: Text(
                          'End of candidates list',
                          style: TextStyle(color: textSecondary, fontSize: 14),
                        ),
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
        floatingActionButton: null,
      ),
    );
  }

  Widget _buildCandidateCard(Map<String, dynamic> candidate, int index) {
    Widget buildHighlightedText(String text, String query) {
      if (query.isEmpty) {
        return GestureDetector(
          onTap: () => _showCandidateDetails(candidate, index),
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        );
      }
      final lowerText = text.toLowerCase();
      final lowerQuery = query.toLowerCase();
      if (!lowerText.contains(lowerQuery)) {
        return GestureDetector(
          onTap: () => _showCandidateDetails(candidate, index),
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
              decoration: TextDecoration.underline,
            ),
          ),
        );
      }
      final startIndex = lowerText.indexOf(lowerQuery);
      final endIndex = startIndex + query.length;
      return GestureDetector(
        onTap: () => _showCandidateDetails(candidate, index),
        child: RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
              decoration: TextDecoration.underline,
            ),
            children: [
              TextSpan(text: text.substring(0, startIndex)),
              TextSpan(
                text: text.substring(startIndex, endIndex),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  backgroundColor: Colors.yellow,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              TextSpan(text: text.substring(endIndex)),
            ],
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 20.0),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Header with name and edit button
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (widget.isAdmin && isSelectingForDownload)
                  Checkbox(
                    value: selectedCandidateIndexes.contains(index),
                    onChanged: (checked) {
                      setState(() {
                        if (checked == true) {
                          selectedCandidateIndexes.add(index);
                        } else {
                          selectedCandidateIndexes.remove(index);
                        }
                      });
                    },
                  ),
                // Candidate name
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onLongPress: () {
                      if (widget.isAdmin && !isSelectingForDownload) {
                        setState(() {
                          isSelectingForDownload = true;
                          selectedCandidateIndexes.add(index);
                        });
                      }
                    },
                    onTap: () => _showCandidateDetails(candidate, index),
                    child: AbsorbPointer(
                      child: Text(
                        (candidate['name'] ?? '').toString(),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Color(0xFF000000),
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _editCandidate(index),
                  icon: Icon(
                    Icons.edit_outlined,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  tooltip: 'Edit Candidate',
                ),
                if (widget.isAdmin)
                  IconButton(
                    onPressed: () => _removeCandidate(index),
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    tooltip: 'Delete Candidate',
                  ),
              ],
            ),
            const SizedBox(height: 8),
            // Tags row (experience, role)
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.green,
                      width: 1,
                    ), // BoxDecoration border OK
                  ),
                  child: Text(
                    (candidate['experience'] ?? '').toString(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.green,
                        width: 1,
                      ), // BoxDecoration border OK
                    ),
                    child: Text(
                      (candidate['role'] ?? '').toString(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            // Candidate details
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow(
                        Icons.location_on_outlined,
                        (candidate['location'] ?? '').toString(),
                      ),
                      SizedBox(height: 8),
                      _buildDetailRow(
                        Icons.school_outlined,
                        (candidate['qualification'] ?? '').toString(),
                      ),
                      SizedBox(height: 8),
                      _buildDetailRow(
                        Icons.calendar_today_outlined,
                        'Added: ${(candidate['addedDate'] ?? '').toString()}',
                      ),
                    ],
                  ),
                ),
                // Rating display (always show)
                Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 20),
                        SizedBox(width: 4),
                        Text(
                          (candidate['rating'] ?? '').toString(),
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Rating',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                        color: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.color?.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            // Action buttons
            Row(
              children: [
                if (currentUserRole == 'admin') ...[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _goForInterview(index),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: lightGreen,
                        foregroundColor: interviewTextColor,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('GFI'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (dialogContext) {
                            return Dialog(
                              insetPadding: const EdgeInsets.all(16),
                              child: Container(
                                width: double.infinity,
                                constraints: BoxConstraints(
                                  maxHeight:
                                      MediaQuery.of(context).size.height * 0.9,
                                ),
                                child: CandidatePopupForm(
                                  userId: userId,
                                  initialPhone: (candidate['phone'] ?? '')
                                      .toString(),
                                  initialName: (candidate['name'] ?? '')
                                      .toString(),
                                  initialRole: (candidate['role'] ?? '')
                                      .toString(),
                                  initialLocation: (candidate['location'] ?? '')
                                      .toString(),
                                  initialQualification:
                                      (candidate['qualification'] ?? '')
                                          .toString(),
                                  initialExperience:
                                      (candidate['experience'] ?? '')
                                          .toString(),
                                  initialInterviewTime:
                                      (candidate['interviewTime'] ?? '')
                                          .toString(),
                                  onlyEditTime: true,
                                  onBookInterview: (candidateData) {
                                    Navigator.pop(dialogContext);
                                    setState(() {
                                      allCandidates[index]['interviewTime'] =
                                          candidateData['interviewTime'];
                                    });
                                    _notificationService.addNotification(
                                      title: 'Interview Rescheduled',
                                      message:
                                          'Interview rescheduled with ${(candidate['name'] ?? '').toString()}',
                                      type: NotificationType.reschedule,
                                      candidateName: (candidate['name'] ?? '')
                                          .toString(),
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Interview rescheduled with ${(candidate['name'] ?? '').toString()}',
                                        ),
                                        backgroundColor: Colors.orange,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: lightOrange,
                        foregroundColor: rescheduleTextColor,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Reschedule'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: (allCandidates[index]['reached'] ?? false)
                          ? null
                          : () async {
                              bool success = await _markReached(index);
                              if (success) {
                                setState(() {
                                  allCandidates[index]['reached'] = true;
                                });
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: lightRed,
                        foregroundColor: reachedTextColor,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Reached',
                        style: TextStyle(
                          color: Color(0xFFFF3535),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _goForInterview(index),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: lightGreen,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'GFI',
                        style: TextStyle(
                          color: Color(0xFF319582),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (dialogContext) {
                            return Dialog(
                              insetPadding: const EdgeInsets.all(16),
                              child: Container(
                                width: double.infinity,
                                constraints: BoxConstraints(
                                  maxHeight:
                                      MediaQuery.of(context).size.height * 0.9,
                                ),
                                child: CandidatePopupForm(
                                  userId: userId,
                                  initialPhone: (candidate['phone'] ?? '')
                                      .toString(),
                                  initialName: (candidate['name'] ?? '')
                                      .toString(),
                                  initialRole: (candidate['role'] ?? '')
                                      .toString(),
                                  initialLocation: (candidate['location'] ?? '')
                                      .toString(),
                                  initialQualification:
                                      (candidate['qualification'] ?? '')
                                          .toString(),
                                  initialExperience:
                                      (candidate['experience'] ?? '')
                                          .toString(),
                                  initialInterviewTime:
                                      (candidate['interviewTime'] ?? '')
                                          .toString(),
                                  onlyEditTime: true,
                                  onBookInterview: (candidateData) {
                                    Navigator.pop(dialogContext);
                                    setState(() {
                                      allCandidates[index]['interviewTime'] =
                                          candidateData['interviewTime'];
                                    });
                                    _notificationService.addNotification(
                                      title: 'Interview Rescheduled',
                                      message:
                                          'Interview rescheduled with ${(candidate['name'] ?? '').toString()}',
                                      type: NotificationType.reschedule,
                                      candidateName: (candidate['name'] ?? '')
                                          .toString(),
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Interview rescheduled with ${(candidate['name'] ?? '').toString()}',
                                        ),
                                        backgroundColor: Colors.orange,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: lightOrange,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Reschedule',
                        style: TextStyle(
                          color: Color(0xFF726E02),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _markReached(index),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: lightRed,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Reached',
                        style: TextStyle(
                          color: Color(0xFFFF3535),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14, color: textSecondary),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // Download logic (mobile/desktop only)
  Future<void> _downloadSelectedCandidates() async {
    List<Map<String, dynamic>> candidatesToExport;
    if (selectedCandidateIndexes.isEmpty) {
      candidatesToExport = List<Map<String, dynamic>>.from(allCandidates);
    } else {
      candidatesToExport = selectedCandidateIndexes
          .map((i) => allCandidates[i])
          .toList();
    }
    if (candidatesToExport.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No candidates to export'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    var excelFile = excel.Excel.createExcel();
    var sheetObject = excelFile['Candidates'];
    // Header
    sheetObject.appendRow([
      'ID',
      'Name',
      'Role',
      'Experience',
      'Location',
      'Qualification',
      'Age',
      'Rating',
      'Added Date',
      'Notes',
      'Interview Time',
      'Status',
    ]);
    for (var c in candidatesToExport) {
      sheetObject.appendRow([
        c['id'] ?? '',
        c['name'] ?? '',
        c['role'] ?? '',
        c['experience'] ?? '',
        c['location'] ?? '',
        c['qualification'] ?? '',
        c['age'] ?? '',
        c['rating'] ?? '',
        c['addedDate'] ?? '',
        c['notes'] ?? '',
        c['interviewTime'] ?? '',
        c['status'] ?? '',
      ]);
    }
    final fileBytes = excelFile.encode();
    final fileName =
        'candidates_export_${DateTime.now().millisecondsSinceEpoch}.xlsx';
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(fileBytes!);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Excel file saved: ${file.path}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // // http://localhost:8080/v1/candidates
  // Future<void> fetchCandidates() async {
  //   final response = await http.get(
  //     Uri.parse('http://localhost:8080/v1/candidates'),
  //   );
  //   if (response.statusCode == 200) {
  //     final List<dynamic> data = json.decode(response.body);
  //     // Convert to List<Map<String, dynamic>>
  //     setState(() {
  //       allCandidates = List<Map<String, dynamic>>.from(data);
  //     });
  //   } else {
  //     throw Exception('Failed to load candidates');
  //   }
  // }

  // get dta from service and load on allCandidates
  Future<void> loadCandidates() async {
    try {
      final candidates = await CandidateService.fetchCandidates(userId);
      setState(() {
        allCandidates = candidates;
      });
    } catch (e) {
      print('Error fetching candidates: $e');
    }
  }

  Future<bool> goForInterviewSubmit(String clientId) async {
    try {
      final gfiCheck = await CandidateService.goForInterview(clientId, userId);
      return gfiCheck;
    } catch (e) {
      print('Erro go for interview');
      return false;
    }
  }
}
