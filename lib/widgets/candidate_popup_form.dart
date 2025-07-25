import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../services/and_candidate_service.dart';
import '../models/candidate_create_model.dart';
import '../data/companies_data.dart';
import '../models/company_model.dart';

class CandidatePopupForm extends StatefulWidget {
  final String initialPhone;
  final String? initialName;
  final String? initialRole;
  final String? initialLocation;
  final String? initialQualification;
  final String? initialExperience;
  final String? initialInterviewTime;
  final bool onlyEditTime;
  final void Function(Map<String, dynamic> candidateData) onBookInterview;
  final VoidCallback? onCompanyAdded;

  final String userId;

  const CandidatePopupForm({
    super.key,
    required this.initialPhone,
    this.initialName,
    this.initialRole,
    this.initialLocation,
    this.initialQualification,
    this.initialExperience,
    this.initialInterviewTime,
    this.onlyEditTime = false,
    required this.onBookInterview,
    this.onCompanyAdded,
    required this.userId,
  });

  @override
  State<CandidatePopupForm> createState() => _CandidatePopupFormState();
}

class _CandidatePopupFormState extends State<CandidatePopupForm> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _mobileController = TextEditingController();
  final _experienceController = TextEditingController();

  // Selection states
  String? selectedLocality;
  String? selectedJobCategory;
  List<String> selectedQualifications = [];
  String? selectedCompanyId;
  String? selectedTimeSlot;
  bool isResumeUploaded = false;
  String? resumeFileName;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  // Data from database
  // List<String> localities = [];
  List<String> localities = [];
  List<String> jobCategories = [];
  // List<Company> get companies => globalCompanies;
  List<Company> companies = globalCompanies;
  Company? selectedCompany;

  // Static options (these could also come from database)
  // final List<String> jobCategories = [
  //   'Inside Sales',
  //   'Developer',
  //   'UI/UX Designer',
  //   'Marketing',
  //   'HR Executive',
  // ];

  final List<String> qualifications = [
    '10th',
    '12th',
    'Graduate',
    'Post Graduate',
    'Diploma',
  ];

  @override
  void initState() {
    super.initState();
    _mobileController.text = widget.initialPhone;
    // Use initial values if provided, otherwise leave empty
    if (widget.initialName != null && widget.initialName!.isNotEmpty) {
      final nameParts = widget.initialName!.split(' ');
      _firstNameController.text = nameParts.first;
      if (nameParts.length > 1) {
        _lastNameController.text = nameParts.sublist(1).join(' ');
      }
    }
    if (widget.initialExperience != null) {
      _experienceController.text = widget.initialExperience!;
    }
    // Age is not passed, so leave as is unless you add initialAge
    // Set other fields if initial values are provided
    if (widget.initialLocation != null) {
      selectedLocality = widget.initialLocation;
    }
    if (widget.initialRole != null) {
      selectedJobCategory = widget.initialRole;
    }
    if (widget.initialQualification != null &&
        widget.initialQualification!.isNotEmpty) {
      selectedQualifications = widget.initialQualification!
          .split(',')
          .map((q) => q.trim())
          .toList();
    }
    // Interview time is handled in the date/time picker logic
    // companies already set from globalCompanies
    // _loadDataFromDatabase(); // Not needed, using static data
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _ageController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  Future<void> _loadDataFromDatabase() async {
    try {
      // final databaseService = DatabaseService();
      // final loadedLocalities = await databaseService.getLocalities();
      final loadedLocalities = await AddCandidateService.fetchLocalityNames(
        "1",
      );
      final loadedJobRoleCategories =
          await AddCandidateService.fetchjobCategories("1");
      final loadedCompanys =
          await AddCandidateService.fetchJobIdAndCompanyNames("1");
      setState(() {
        localities = loadedLocalities;
        jobCategories = loadedJobRoleCategories;
        // companies = loadedCompanys; // Not needed, using static data
      });
      // if (globalCompanies.isEmpty) {
      //   final loadedCompanies = await databaseService.getCompanies();
      //   setState(() {
      //     globalCompanies
      //       ..clear()
      //       ..addAll(loadedCompanies);
      //   });
      // }
    } catch (e) {
      // setState(() {
      //   if (globalCompanies.isEmpty) {
      //     globalCompanies
      //       ..clear()
      //       ..addAll([
      //         Company(
      //           id: '1',
      //           name: 'Client 1',
      //           address: 'The Skyline • Seoul Plaza Rd',
      //         ),
      //         Company(
      //           id: '2',
      //           name: 'Client 2',
      //           address: 'Tech Park • Whitefield',
      //         ),
      //         Company(
      //           id: '3',
      //           name: 'Client 3',
      //           address: 'Business Hub • Koramangala',
      //         ),
      //       ]);
      //   }
      // });
      print("Error loading localities and job role categories: $e");
    }
  }

  // Resume upload is now a placeholder (no file picking)
  void _showResumeUploadMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Resume upload is disabled in this version.'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryBlue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        selectedTimeSlot = null;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryBlue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
        final timeString =
            '${picked.format(context)} - ${picked.replacing(hour: picked.hour + 1).format(context)}';
        selectedTimeSlot = timeString;
      });
    }
  }

  void _onCompanySelected(String companyId) {
    setState(() {
      selectedCompanyId = companyId;
      selectedCompany = companies.firstWhere(
        (company) => company.id == companyId,
      );
    });
  }

  bool _showSelectionErrors = false;

  // void _bookInterview() {
  //   setState(() {
  //     _showSelectionErrors = true;
  //   });
  //   if (_formKey.currentState!.validate()) {
  //     if (selectedLocality == null ||
  //         selectedJobCategory == null ||
  //         selectedQualifications.isEmpty ||
  //         selectedCompanyId == null ||
  //         selectedDate == null ||
  //         selectedTime == null) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text('Please fill all required fields'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //       return;
  //     }
  //     widget.onBookInterview({
  //       'name':
  //           ('${_firstNameController.text.trim()} ${_lastNameController.text.trim()}')
  //               .trim(),
  //       'experience': _experienceController.text,
  //       'role': selectedJobCategory ?? '',
  //       'age': int.tryParse(_ageController.text) ?? 0,
  //       'location': selectedLocality ?? '',
  //       'qualification': selectedQualifications.isNotEmpty
  //           ? selectedQualifications.join(', ')
  //           : '',
  //       'addedDate': DateTime.now().toString().split(' ')[0],
  //       'status': 'active',
  //       'rating': 0.0,
  //       'notes': '',
  //       'phone': _mobileController.text,
  //       'company': selectedCompany?.companyName ?? '',
  //     });
  //   }
  // }

  void _bookInterview() async {
    setState(() {
      _showSelectionErrors = true;
    });

    if (_formKey.currentState!.validate()) {
      if (selectedLocality == null ||
          selectedJobCategory == null ||
          selectedQualifications.isEmpty ||
          selectedCompanyId == null ||
          selectedDate == null ||
          selectedTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill all required fields'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final DateTime interviewDateTime = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        selectedTime!.hour,
        selectedTime!.minute,
      );

      final candidate = CandidateCreateDTO(
        name:
            ('${_firstNameController.text.trim()} ${_lastNameController.text.trim()}')
                .trim(),
        role: selectedJobCategory ?? '',
        location: selectedLocality ?? '',
        qualification: selectedQualifications.join(', '),
        experience: _experienceController.text,
        age: int.tryParse(_ageController.text) ?? 0,
        isActiveCandidate: true,
        phone: _mobileController.text,
        interviewTime: interviewDateTime
            .toIso8601String()
            .substring(0, 16)
            .replaceFirst('T', ' '), // 'yyyy-MM-dd HH:mm'
        userId:
            int.tryParse(widget.userId) ?? 0, // Pass this via widget or state
        companyId: int.tryParse(selectedCompanyId!) ?? 0,
      );

      // Add company name to candidateData map for UI
      final candidateData = {
        'name': ('${_firstNameController.text.trim()} ${_lastNameController.text.trim()}').trim(),
        'role': selectedJobCategory ?? '',
        'location': selectedLocality ?? '',
        'qualification': selectedQualifications.join(', '),
        'experience': _experienceController.text,
        'age': int.tryParse(_ageController.text) ?? 0,
        'isActiveCandidate': true,
        'phone': _mobileController.text,
        'interviewTime': interviewDateTime
            .toIso8601String()
            .substring(0, 16)
            .replaceFirst('T', ' '),
        'userId': int.tryParse(widget.userId) ?? 0,
        'companyId': int.tryParse(selectedCompanyId!) ?? 0,
        'company': selectedCompany?.name ?? '',
      };

      final success = await AddCandidateService.createCandidate(
        candidate,
        widget.userId,
      );

      if (success) {
        // DEBUG: Print candidateData to verify company field
        print('DEBUG candidateData (onBookInterview):');
        print(candidateData);
        widget.onBookInterview(candidateData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Candidate added successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // or reset form
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to add candidate'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildDateTimeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Available Slots',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: GestureDetector(
                onTap: _selectDate,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(8),
                    color: selectedDate != null
                        ? Colors.green.withOpacity(0.1)
                        : Colors.white,
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: selectedDate != null
                            ? Colors.green
                            : Colors.grey,
                        size: 24,
                      ),
                      const SizedBox(height: 8),
                      if (selectedDate != null) ...[
                        Text(
                          _getWeekdayName(selectedDate!.weekday),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        Text(
                          '${selectedDate!.day}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        Text(
                          _getMonthName(selectedDate!.month),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.green,
                          ),
                        ),
                      ] else ...[
                        const Text(
                          'Select Date',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 3,
              child: GestureDetector(
                onTap: selectedDate != null ? _selectTime : null,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: selectedDate != null
                          ? Colors.grey.withOpacity(0.3)
                          : Colors.grey.withOpacity(0.1),
                    ),
                    borderRadius: BorderRadius.circular(8),
                    color: selectedTime != null
                        ? Colors.green.withOpacity(0.1)
                        : Colors.white,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.access_time,
                        color: selectedTime != null
                            ? Colors.green
                            : selectedDate != null
                            ? Colors.grey
                            : Colors.grey.withOpacity(0.5),
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        selectedTime != null
                            ? selectedTime!.format(context)
                            : selectedDate != null
                            ? 'Select Time'
                            : 'Select Date First',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: selectedTime != null
                              ? Colors.green
                              : selectedDate != null
                              ? Colors.grey
                              : Colors.grey.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getWeekdayName(int weekday) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdays[weekday - 1];
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: primaryBlue,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Add Candidate Pop-up',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.code, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Form content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Basic Info Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          // First Name
                          TextFormField(
                            controller: _firstNameController,
                            decoration: const InputDecoration(
                              labelText: 'First Name',
                              border: UnderlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(vertical: 8),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          // Last Name
                          TextFormField(
                            controller: _lastNameController,
                            decoration: const InputDecoration(
                              labelText: 'Last Name',
                              border: UnderlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Age
                          TextFormField(
                            controller: _ageController,
                            decoration: const InputDecoration(
                              labelText: 'Age',
                              border: UnderlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(vertical: 8),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              final age = int.tryParse(value);
                              if (age == null) {
                                return 'Enter a valid number';
                              }
                              if (age < 18 || age > 65) {
                                return 'Enter age between 18 and 65';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          // Experience
                          TextFormField(
                            controller: _experienceController,
                            decoration: const InputDecoration(
                              labelText: 'Experience',
                              hintText: 'e.g. 2 years, 6 months',
                              border: UnderlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Mobile Number
                          TextFormField(
                            controller: _mobileController,
                            decoration: const InputDecoration(
                              labelText: 'Mobile Number',
                              border: UnderlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(vertical: 8),
                            ),
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              final phoneRegExp = RegExp(r'^\d{10} ?$');
                              if (!phoneRegExp.hasMatch(value)) {
                                return 'Enter a valid 10-digit number';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Locality Section
                    _buildSectionTitle('Locality'),
                    const SizedBox(height: 8),
                    localities.isEmpty
                        ? const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                primaryBlue,
                              ),
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  ...localities.take(3).map((locality) {
                                    final isSelected =
                                        selectedLocality == locality;
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedLocality = locality;
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? primaryBlue
                                              : Colors.blue.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          border: Border.all(
                                            color: isSelected
                                                ? primaryBlue
                                                : Colors.blue.withOpacity(0.3),
                                          ),
                                        ),
                                        child: Text(
                                          locality,
                                          style: TextStyle(
                                            color: isSelected
                                                ? Colors.white
                                                : primaryBlue,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                  if (localities.length > 3)
                                    GestureDetector(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: const Text(
                                                'All Locations',
                                              ),
                                              content: SizedBox(
                                                width: double.maxFinite,
                                                child: ListView(
                                                  shrinkWrap: true,
                                                  children: localities.map((
                                                    locality,
                                                  ) {
                                                    final isSelected =
                                                        selectedLocality ==
                                                        locality;
                                                    return ListTile(
                                                      title: Text(locality),
                                                      trailing: isSelected
                                                          ? const Icon(
                                                              Icons.check,
                                                              color:
                                                                  primaryBlue,
                                                            )
                                                          : null,
                                                      onTap: () {
                                                        setState(() {
                                                          selectedLocality =
                                                              locality;
                                                        });
                                                        Navigator.pop(context);
                                                      },
                                                    );
                                                  }).toList(),
                                                ),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  child: const Text('Close'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          border: Border.all(
                                            color: Colors.blue.withOpacity(0.3),
                                          ),
                                        ),
                                        child: const Text(
                                          'View More',
                                          style: TextStyle(
                                            color: primaryBlue,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              if (_showSelectionErrors &&
                                  selectedLocality == null)
                                const Padding(
                                  padding: EdgeInsets.only(top: 4, left: 4),
                                  child: Text(
                                    'Please select a locality',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                    const SizedBox(height: 24),
                    // Job Category Section
                    _buildSectionTitle('Job Category'),
                    const SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ...jobCategories.take(3).map((category) {
                              final isSelected =
                                  selectedJobCategory == category;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedJobCategory = category;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.green
                                        : Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.green
                                          : Colors.green.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Text(
                                    category,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.green,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              );
                            }),
                            if (jobCategories.length > 3)
                              GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text('All Job Roles'),
                                        content: SizedBox(
                                          width: double.maxFinite,
                                          child: ListView(
                                            shrinkWrap: true,
                                            children: jobCategories.map((
                                              category,
                                            ) {
                                              final isSelected =
                                                  selectedJobCategory ==
                                                  category;
                                              return ListTile(
                                                title: Text(category),
                                                trailing: isSelected
                                                    ? const Icon(
                                                        Icons.check,
                                                        color: Colors.green,
                                                      )
                                                    : null,
                                                onTap: () {
                                                  setState(() {
                                                    selectedJobCategory =
                                                        category;
                                                  });
                                                  Navigator.pop(context);
                                                },
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text('Close'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.green.withOpacity(0.3),
                                    ),
                                  ),
                                  child: const Text(
                                    'View More',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        if (_showSelectionErrors && selectedJobCategory == null)
                          const Padding(
                            padding: EdgeInsets.only(top: 4, left: 4),
                            child: Text(
                              'Please select a job category',
                              style: TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Qualification Section
                    _buildSectionTitle('Qualification'),
                    const SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: qualifications.map((qualification) {
                            final isSelected = selectedQualifications.contains(
                              qualification,
                            );
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    selectedQualifications.remove(
                                      qualification,
                                    );
                                  } else {
                                    selectedQualifications.add(qualification);
                                  }
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.orange
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.orange),
                                ),
                                child: Text(
                                  qualification,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.orange,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        if (_showSelectionErrors &&
                            selectedQualifications.isEmpty)
                          const Padding(
                            padding: EdgeInsets.only(top: 4, left: 4),
                            child: Text(
                              'Please select at least one qualification',
                              style: TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Upload Resume Section
                    _buildSectionTitle('Upload Resume'),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _showResumeUploadMessage,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isResumeUploaded
                              ? Colors.green.withOpacity(0.1)
                              : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isResumeUploaded
                                ? Colors.green
                                : Colors.grey.withOpacity(0.3),
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              isResumeUploaded
                                  ? Icons.check_circle
                                  : Icons.cloud_upload_outlined,
                              size: 40,
                              color: isResumeUploaded
                                  ? Colors.green
                                  : primaryBlue,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              isResumeUploaded
                                  ? (resumeFileName ?? 'Resume.pdf')
                                  : 'Upload Resume',
                              style: TextStyle(
                                fontSize: 14,
                                color: isResumeUploaded
                                    ? Colors.green
                                    : textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (!isResumeUploaded)
                              const Text(
                                'Tap to select resume file',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: textSecondary,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Company Selection
                    _buildSectionTitle('Select Company'),
                    const SizedBox(height: 8),

                    // Dropdown that controls radio selection logic
                    DropdownButtonFormField<Company>(
                      value: selectedCompany,
                      items: companies.map((company) {
                        return DropdownMenuItem<Company>(
                          value: company,
                          child: Text(company.name),
                        );
                      }).toList(),
                      onChanged: (Company? selected) {
                        if (selected != null) {
                          setState(() {
                            selectedCompany = selected;
                            selectedCompanyId = selected.id;
                            _onCompanySelected(selected.id);
                          });
                        }
                      },
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        hintText: 'Select a company',
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Show error only if no selection was made
                    if (_showSelectionErrors && selectedCompanyId == null)
                      const Padding(
                        padding: EdgeInsets.only(top: 4, left: 4),
                        child: Text(
                          'Please select a company',
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                    const SizedBox(height: 24),

                    // Interview Schedule Section
                    _buildSectionTitle('Interview Schedule'),
                    const SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDateTimeSelector(),
                        if (_showSelectionErrors &&
                            (selectedDate == null || selectedTime == null))
                          const Padding(
                            padding: EdgeInsets.only(top: 4, left: 4),
                            child: Text(
                              'Please select date and time',
                              style: TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (selectedCompany != null) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.green.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.business,
                              color: Colors.green,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    selectedCompany!.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.green,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  // Text(
                                  //   selectedCompany!.address,
                                  //   style: TextStyle(
                                  //     fontSize: 12,
                                  //     color: Colors.green.shade700,
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
          // Book Interview Button
          Container(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _bookInterview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'BOOK INTERVIEW',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
