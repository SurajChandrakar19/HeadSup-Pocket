import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../utils/app_colors.dart';
import 'dashboard_shell_screen.dart';

class DataVaultPage extends StatefulWidget {
  const DataVaultPage({super.key});

  @override
  State<DataVaultPage> createState() => _DataVaultPageState();
}

class _DataVaultPageState extends State<DataVaultPage> {
  final int _selectedIndex = 4; // Data Vault is selected
  List<CandidateModel> allCandidates = [];
  List<CandidateModel> databaseCandidates = [];
  List<CandidateModel> unlockedCandidates = [];
  String selectedStatusFilter = 'All';
  String selectedGenderFilter = 'All';
  String selectedExperienceFilter = 'All';
  String selectedLocationFilter = 'All';
  String selectedUploadDateFilter = 'All';
  bool isDatabaseTabSelected = true;

  // Track which candidates' unlock panels are open (by name+phone for uniqueness)
  Set<String> openUnlockPanelKeys = {};

  @override
  void initState() {
    super.initState();
    _initializeCandidates();
  }

  void _initializeCandidates() {
    allCandidates = [
      CandidateModel(
        name: 'Tanvi Mandal',
        location: 'Jayanagar, Bangalore, 5.6 Kms',
        qualification: 'Graduate, B.Com',
        languages: 'Kannada, English, Hindi',
        experience: 'Fresher',
        gender: 'Female, 25Y',
        status: 'Interested',
        statusColor: _getStatusColor('Interested'),
        role: 'Marketing Executive',
        uploadDate: '19 Jan 2025',
        phone: '+91 9876543210',
        email: 'tanvi.mandal@email.com',
        isUnlocked: false,
      ),
      CandidateModel(
        name: 'Rahul Sharma',
        location: 'Koramangala, Bangalore, 3.2 Kms',
        qualification: 'Graduate, BBA',
        languages: 'English, Hindi, Kannada',
        experience: 'Fresher',
        gender: 'Male, 24Y',
        status: 'RNR',
        statusColor: _getStatusColor('RNR'),
        role: 'Sales Executive',
        uploadDate: '18 Jan 2025',
        phone: '+91 9876543211',
        email: 'rahul.sharma@email.com',
        isUnlocked: false,
      ),
      CandidateModel(
        name: 'Priya Singh',
        location: 'Whitefield, Bangalore, 8.1 Kms',
        qualification: 'Graduate, B.Com',
        languages: 'Hindi, English, Tamil',
        experience: 'Fresher',
        gender: 'Female, 23Y',
        status: 'Busy',
        statusColor: _getStatusColor('Busy'),
        role: 'Marketing Executive',
        uploadDate: '17 Jan 2025',
        phone: '+91 9876543212',
        email: 'priya.singh@email.com',
        isUnlocked: false,
      ),
      CandidateModel(
        name: 'Amit Verma',
        location: 'Indiranagar, Bangalore, 2.5 Kms',
        qualification: 'Graduate, B.Sc',
        languages: 'English, Hindi',
        experience: '1-2 Years',
        gender: 'Male, 26Y',
        status: 'Pending',
        statusColor: _getStatusColor('Pending'),
        role: 'Field Sales',
        uploadDate: '16 Jan 2025',
        phone: '+91 9876543213',
        email: 'amit.verma@email.com',
        isUnlocked: false,
      ),
      CandidateModel(
        name: 'Sneha Rao',
        location: 'HSR Layout, Bangalore, 4.0 Kms',
        qualification: 'Graduate, BCA',
        languages: 'Kannada, English',
        experience: '3-5 Years',
        gender: 'Female, 28Y',
        status: 'Interested',
        statusColor: _getStatusColor('Interested'),
        role: 'Team Lead',
        uploadDate: '15 Jan 2025',
        phone: '+91 9876543214',
        email: 'sneha.rao@email.com',
        isUnlocked: false,
      ),
      CandidateModel(
        name: 'Vikram Desai',
        location: 'BTM Layout, Bangalore, 6.3 Kms',
        qualification: 'Graduate, B.Tech',
        languages: 'English, Hindi',
        experience: '5+ Years',
        gender: 'Male, 30Y',
        status: 'Contact again',
        statusColor: _getStatusColor('Contact again'),
        role: 'Manager',
        uploadDate: '14 Jan 2025',
        phone: '+91 9876543215',
        email: 'vikram.desai@email.com',
        isUnlocked: false,
      ),
      CandidateModel(
        name: 'Meera Nair',
        location: 'Marathahalli, Bangalore, 7.8 Kms',
        qualification: 'Graduate, M.Com',
        languages: 'English, Malayalam',
        experience: '1-2 Years',
        gender: 'Female, 27Y',
        status: 'Busy',
        statusColor: _getStatusColor('Busy'),
        role: 'Accountant',
        uploadDate: '13 Jan 2025',
        phone: '+91 9876543216',
        email: 'meera.nair@email.com',
        isUnlocked: false,
      ),
    ];
    
    // Initially all candidates are in database
    databaseCandidates = List.from(allCandidates);
    unlockedCandidates = [];
    filteredDatabaseCandidates = List.from(databaseCandidates);
    filteredUnlockedCandidates = List.from(unlockedCandidates);
  }

  void _unlockCandidate(CandidateModel candidate) {
    setState(() {
      // Remove from database candidates
      databaseCandidates.removeWhere((c) => c.name == candidate.name && c.phone == candidate.phone);
      // Mark as unlocked and add to top of unlocked candidates
      candidate.isUnlocked = true;
      unlockedCandidates.insert(0, candidate);
      // Keep the slide-down open for this candidate
      openUnlockPanelKeys.add(candidate.name + candidate.phone);
      _applyFilters();
    });
    // No navigation, just unlock in-place
  }

  List<CandidateModel> filteredDatabaseCandidates = [];
  List<CandidateModel> filteredUnlockedCandidates = [];

  List<CandidateModel> get currentCandidates {
    return isDatabaseTabSelected ? filteredDatabaseCandidates : filteredUnlockedCandidates;
  }

  void _applyFilters() {
    setState(() {
      filteredDatabaseCandidates = databaseCandidates.where((c) =>
        (selectedStatusFilter == 'All' || c.status.toString().toLowerCase() == selectedStatusFilter.toLowerCase()) &&
        (selectedGenderFilter == 'All' || c.gender.toLowerCase().startsWith(selectedGenderFilter.toLowerCase())) &&
        (selectedExperienceFilter == 'All' || c.experience.toLowerCase().contains(selectedExperienceFilter.toLowerCase())) &&
        (selectedLocationFilter == 'All' || c.location.toLowerCase().contains(selectedLocationFilter.toLowerCase().trim())) &&
        (selectedUploadDateFilter == 'All' || c.uploadDate.toLowerCase().contains(selectedUploadDateFilter.toLowerCase()))
      ).toList();
      filteredUnlockedCandidates = unlockedCandidates.where((c) =>
        (selectedStatusFilter == 'All' || c.status.toString().toLowerCase() == selectedStatusFilter.toLowerCase()) &&
        (selectedGenderFilter == 'All' || c.gender.toLowerCase().startsWith(selectedGenderFilter.toLowerCase())) &&
        (selectedExperienceFilter == 'All' || c.experience.toLowerCase().contains(selectedExperienceFilter.toLowerCase())) &&
        (selectedLocationFilter == 'All' || c.location.toLowerCase().contains(selectedLocationFilter.toLowerCase().trim())) &&
        (selectedUploadDateFilter == 'All' || c.uploadDate.toLowerCase().contains(selectedUploadDateFilter.toLowerCase()))
      ).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF181A20) : const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF23262B) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const DashboardShellScreen()),
              (route) => false,
            );
          },
        ),
        title: Row(
          children: [
            Text(
              'Data Vault',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[700] : Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '(${databaseCandidates.length},${unlockedCandidates.length})',
                style: TextStyle(
                  color: isDark ? Colors.grey[300] : Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        actions: [
          // Upload Button with improved style and smaller menu
          Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: PopupMenuButton<String>(
              icon: Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[850] : Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.10),
                      blurRadius: 8,
                      spreadRadius: 1,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                width: 38,
                height: 38,
                child: Icon(Icons.add, color: isDark ? Colors.grey[300] : Colors.grey[600], size: 22),
              ),
              color: isDark ? const Color(0xFF23262B) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              itemBuilder: (BuildContext context) => [
                PopupMenuItem<String>(
                  value: 'excel',
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 120, maxWidth: 180),
                    child: Row(
                      children: [
                        Icon(Icons.upload_file, color: isDark ? Colors.white : Colors.black, size: 18),
                        const SizedBox(width: 6),
                        Text('Upload Excel', style: TextStyle(fontSize: 13, color: isDark ? Colors.white : Colors.black)),
                      ],
                    ),
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'google_sheets',
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 120, maxWidth: 180),
                    child: Row(
                      children: [
                        Icon(Icons.table_chart, color: isDark ? Colors.white : Colors.black, size: 18),
                        const SizedBox(width: 6),
                        Text('Google Sheets', style: TextStyle(fontSize: 13, color: isDark ? Colors.white : Colors.black)),
                      ],
                    ),
                  ),
                ),
              ],
              onSelected: _handleUploadOption,
              offset: const Offset(0, 40),
              elevation: 6,
            ),
          ),
          // Filter Button with improved style and smaller menu
          Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: PopupMenuButton<String>(
              icon: Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[850] : Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.10),
                      blurRadius: 8,
                      spreadRadius: 1,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                width: 38,
                height: 38,
                child: Icon(Icons.menu, color: isDark ? Colors.grey[300] : Colors.grey[600], size: 22),
              ),
              color: isDark ? const Color(0xFF23262B) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              itemBuilder: (BuildContext context) => [
                PopupMenuItem<String>(
                  value: 'filter',
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 120, maxWidth: 180),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Filter Options',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        const Divider(height: 10, thickness: 1),
                        _buildFilterOption('By Status', isDark),
                        _buildFilterOption('By Gender', isDark),
                        _buildFilterOption('By Experience', isDark),
                        _buildFilterOption('By Location', isDark),
                        _buildFilterOption('By Upload Date', isDark),
                      ],
                    ),
                  ),
                ),
              ],
              onSelected: (value) {},
              offset: const Offset(0, 40),
              elevation: 6,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab Section
          Container(
            color: isDark ? const Color(0xFF23262B) : Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isDatabaseTabSelected = true;
                    });
                  },
                  child: _buildTab('Database', '(${databaseCandidates.length})', isDatabaseTabSelected, isDark),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isDatabaseTabSelected = false;
                    });
                  },
                  child: _buildTab('Unlocked', '(${unlockedCandidates.length})', !isDatabaseTabSelected, isDark),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Candidate List
          Expanded(
            child: currentCandidates.isEmpty 
                ? Center(
                    child: Text(
                      isDatabaseTabSelected 
                          ? 'No candidates in database'
                          : 'No unlocked candidates yet',
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: currentCandidates.length,
                    itemBuilder: (context, index) {
                      return _buildCandidateCard(currentCandidates[index], isDark);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOption(String title, bool isDark) {
    return InkWell(
      onTap: () => _showFilterDialog(title),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          title,
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black87,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  void _showFilterDialog(String filterType) {
    Navigator.pop(context);
    
    List<String> options = [];
    String currentValue = '';
    
    switch (filterType) {
      case 'By Status':
        options = ['All', 'Interested', 'RNR', 'Busy', 'Pending'];
        currentValue = selectedStatusFilter;
        break;
      case 'By Gender':
        options = ['All', 'Male', 'Female'];
        currentValue = selectedGenderFilter;
        break;
      case 'By Experience':
        options = ['All', 'Fresher', '1-2 Years', '3-5 Years', '5+ Years'];
        currentValue = selectedExperienceFilter;
        break;
      case 'By Location':
        options = ['All', 'Bangalore', 'Mumbai', 'Delhi', 'Chennai'];
        currentValue = selectedLocationFilter;
        break;
      case 'By Upload Date':
        options = ['All', 'Today', 'This Week', 'This Month'];
        currentValue = selectedUploadDateFilter;
        break;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(filterType),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: options.map((option) {
              return RadioListTile<String>(
                title: Text(option),
                value: option,
                groupValue: currentValue,
                onChanged: (value) {
                  setState(() {
                    switch (filterType) {
                      case 'By Status':
                        selectedStatusFilter = value!;
                        break;
                      case 'By Gender':
                        selectedGenderFilter = value!;
                        break;
                      case 'By Experience':
                        selectedExperienceFilter = value!;
                        break;
                      case 'By Location':
                        selectedLocationFilter = value!;
                        break;
                      case 'By Upload Date':
                        selectedUploadDateFilter = value!;
                        break;
                    }
                  });
                  Navigator.pop(context);
                  _applyFilters();
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _handleUploadOption(String option) {
    switch (option) {
      case 'excel':
        _uploadExcelSheet();
        break;
      case 'google_sheets':
        _connectGoogleSheets();
        break;
    }
  }

  Future<void> _uploadExcelSheet() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
      );

      if (result != null) {
        // Simulate adding a new candidate (real implementation would parse the file)
        CandidateModel newCandidate = CandidateModel(
          name: 'New Candidate',
          location: 'Unknown',
          qualification: 'Unknown',
          languages: 'Unknown',
          experience: 'Fresher',
          gender: 'Unknown',
          status: 'Interested',
          statusColor: _getStatusColor('Interested'),
          role: 'Unknown',
          uploadDate: 'Today',
          phone: '+91 0000000000',
          email: 'new@email.com',
          isUnlocked: !isDatabaseTabSelected,
        );
        setState(() {
          if (isDatabaseTabSelected) {
            databaseCandidates.add(newCandidate);
          } else {
            unlockedCandidates.add(newCandidate);
          }
          _applyFilters();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Excel file "${result.files.single.name}" uploaded and candidate added!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error uploading Excel file'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _connectGoogleSheets() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Google Sheets integration coming soon!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Widget _buildTab(String title, String count, bool isSelected, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected 
            ? (isDark ? primaryBlue.withOpacity(0.2) : Colors.blue[100])
            : (isDark ? Colors.grey[800] : Colors.grey[200]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isSelected 
                  ? (isDark ? primaryBlue : Colors.blue[700])
                  : (isDark ? Colors.grey[300] : Colors.grey[600]),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            count,
            style: TextStyle(
              color: isSelected 
                  ? (isDark ? primaryBlue : Colors.blue[700])
                  : (isDark ? Colors.grey[300] : Colors.grey[600]),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCandidateCard(CandidateModel candidate, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF23262B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark 
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with name and role
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      candidate.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      candidate.location,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey[300] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  candidate.role,
                  style: TextStyle(
                    color: Colors.green[700],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Edit'),
                      content: const Text('Edit feature coming soon!'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                },
                child: Icon(
                  Icons.edit, 
                  color: isDark ? Colors.grey[500] : Colors.grey[400], 
                  size: 20
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Details rows
          Row(
            children: [
              Expanded(
                child: _buildDetailRow(Icons.school, candidate.qualification, isDark),
              ),
              Expanded(
                child: _buildDetailRow(Icons.language, candidate.languages, isDark),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDetailRow(Icons.work, candidate.experience, isDark),
              ),
              Expanded(
                child: _buildDetailRow(Icons.person, candidate.gender, isDark),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Communication buttons section (for unlocked candidates)
          if (candidate.isUnlocked) ...[
            // First row of communication buttons
            Row(
              children: [
                Expanded(
                  child: _buildExactScreenshotButton(
                    icon: FontAwesomeIcons.whatsapp,
                    label: 'WhatsApp',
                    color: const Color(0xFF25D366),
                    onTap: () => _showWhatsAppDialog(candidate),
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildExactScreenshotButton(
                    icon: Icons.phone_outlined,
                    label: 'Phone',
                    color: const Color(0xFF2196F3),
                    onTap: () => _launchPhone(candidate.phone),
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildExactScreenshotButton(
                    icon: Icons.schedule_outlined,
                    label: 'Schedule',
                    color: const Color(0xFF9C27B0),
                    onTap: () => _scheduleCall(),
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Second row of communication buttons
            Row(
              children: [
                Expanded(
                child: _buildExactScreenshotButton(
                icon: Icons.sms_outlined,
                label: 'SMS',
                color: const Color(0xFFFF9800),
                onTap: () => _launchSMSWithMessage(
                candidate.phone,
                'Hi,\nI have a job vacancy in your city.\n\nJob: Sales executive\nSalary: up to Rs.35,000\nCall Me: 9818074659',
                ),
                isDark: isDark,
                ),
                ),
                const SizedBox(width: 10),
                Expanded(
                child: _buildExactScreenshotButton(
                icon: Icons.email_outlined,
                label: 'Email',
                color: const Color(0xFFF44336),
                onTap: () => _launchEmailWithMessage(
                candidate.email,
                'Dear Candidate,\n\nI hope this email finds you well.\n\nI have a job vacancy in your city.\n\nJob Details:\nPosition: Sales executive\nSalary: up to Rs.35,000\nContact: 9818074659\n\nBest regards',
                ),
                isDark: isDark,
                ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildRemarksDropdown(candidate, isDark),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Status section
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: candidate.statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: candidate.statusColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    candidate.status,
                    style: TextStyle(
                      color: candidate.statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            // Bottom section with status and unlock button (only for database candidates)
            Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: candidate.statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: candidate.statusColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        candidate.status,
                        style: TextStyle(
                          color: candidate.statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Show the unlock button only if not unlocked and panel not open
                    if (!candidate.isUnlocked && !openUnlockPanelKeys.contains(candidate.name + candidate.phone))
                      ElevatedButton(
                        onPressed: () {
                          final key = candidate.name + candidate.phone;
                          setState(() {
                            openUnlockPanelKeys.add(key);
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        ),
                        child: const Text(
                          'Unlock the candidate',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                  ],
                ),
                // Slide-down panel
                AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  child: (openUnlockPanelKeys.contains(candidate.name + candidate.phone) || candidate.isUnlocked)
                      ? Padding(
                          padding: const EdgeInsets.only(top: 12.0, bottom: 4.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildExactScreenshotButton(
                                      icon: FontAwesomeIcons.whatsapp,
                                      label: 'WhatsApp',
                                      color: const Color(0xFF25D366),
                                      onTap: () => _launchWhatsAppWithMessage(
                                        candidate.phone,
                                        'Hi,\nI have a job vacancy in your city.\n\nJob Details:\nJob: Sales executive\nSalary: up to Rs.35,000\nCall Me: 9818074659',
                                      ),
                                      isDark: isDark,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _buildExactScreenshotButton(
                                      icon: Icons.phone_outlined,
                                      label: 'Phone',
                                      color: const Color(0xFF2196F3),
                                      onTap: () {
                                        _unlockCandidate(candidate);
                                        _launchPhone(candidate.phone);
                                      },
                                      isDark: isDark,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _buildExactScreenshotButton(
                                      icon: Icons.schedule_outlined,
                                      label: 'Schedule',
                                      color: const Color(0xFF9C27B0),
                                      onTap: () {},
                                      isDark: isDark,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildExactScreenshotButton(
                                      icon: Icons.sms_outlined,
                                      label: 'SMS',
                                      color: const Color(0xFFFF9800),
                                      onTap: () => _launchSMSWithMessage(
                                        candidate.phone,
                                        'Hi,\nI have a job vacancy in your city.\n\nJob: Sales executive\nSalary: up to Rs.35,000\nCall Me: 9818074659',
                                      ),
                                      isDark: isDark,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _buildExactScreenshotButton(
                                      icon: Icons.email_outlined,
                                      label: 'Email',
                                      color: const Color(0xFFF44336),
                                      onTap: () => _launchEmailWithMessage(
                                        candidate.email,
                                        'Dear Candidate,\n\nI hope this email finds you well.\n\nI have a job vacancy in your city.\n\nJob Details:\nPosition: Sales executive\nSalary: up to Rs.35,000\nContact: 9818074659\n\nBest regards',
                                      ),
                                      isDark: isDark,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _buildRemarksDropdown(candidate, isDark),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          Text(
            'Uploaded date\n${candidate.uploadDate}',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey[400] : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  // WhatsApp Dialog
  void _showWhatsAppDialog(CandidateModel candidate) {
    final TextEditingController messageController = TextEditingController();
    messageController.text = '''Hi,
I have a job vacancy in your city.

Job Details:
Job: Sales executive
Salary: up to Rs.35,000
Call Me: 9818074659''';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Dialog(
          backgroundColor: isDark ? const Color(0xFF23262B) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Send Whatsapp',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Message',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2A2D32) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: messageController,
                    maxLines: 6,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(12),
                      hintText: 'Enter your message...',
                      hintStyle: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: isDark ? Colors.grey[300] : Colors.grey[600],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _launchWhatsAppWithMessage(candidate.phone, messageController.text);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Send'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // SMS Dialog
  void _showSMSDialog(CandidateModel candidate) {
    final TextEditingController messageController = TextEditingController();
    messageController.text = '''Hi,
I have a job vacancy in your city.

Job: Sales executive
Salary: up to Rs.35,000
Call Me: 9818074659''';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Dialog(
          backgroundColor: isDark ? const Color(0xFF23262B) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Send Sms',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Message',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2A2D32) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: messageController,
                    maxLines: 5,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(12),
                      hintText: 'Enter your message...',
                      hintStyle: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: isDark ? Colors.grey[300] : Colors.grey[600],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _launchSMSWithMessage(candidate.phone, messageController.text);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Send'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Email Dialog
  void _showEmailDialog(CandidateModel candidate) {
    final TextEditingController messageController = TextEditingController();
    messageController.text = '''Dear Candidate,

I hope this email finds you well.

I have a job vacancy in your city.

Job Details:
Position: Sales executive
Salary: up to Rs.35,000
Contact: 9818074659

Best regards''';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Dialog(
          backgroundColor: isDark ? const Color(0xFF23262B) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Send Email',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Message',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2A2D32) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: messageController,
                    maxLines: 8,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(12),
                      hintText: 'Enter your message...',
                      hintStyle: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: isDark ? Colors.grey[300] : Colors.grey[600],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _launchEmailWithMessage(candidate.email, messageController.text);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Send'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildExactScreenshotButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // CORRECTED: Dropdown with proper positioning and reduced gaps
  Widget _buildRemarksDropdown(CandidateModel candidate, bool isDark) {
    final List<String> statusOptions = [
      'Interested',
      'RNR',
      'Busy',
      'Contact again',
      'Pending',
      'Switched off',
      'Not Interested',
      'Not Suitable',
      'Wrong Number',
    ];

    return PopupMenuButton<String>(
      offset: const Offset(0, 40), // Position dropdown below the button
      onSelected: (String? newValue) {
        if (newValue != null) {
          setState(() {
            candidate.status = newValue;
            candidate.statusColor = _getStatusColor(newValue);
          });
        }
      },
      itemBuilder: (BuildContext context) => [
        // Header item (non-selectable)
        PopupMenuItem<String>(
          enabled: false,
          height: 32, // Reduced height
          child: Text(
            'Call Status',
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        // Divider with reduced space
        const PopupMenuDivider(height: 8),
        // Status options with reduced height
        ...statusOptions.map((String status) {
          Color statusColor = _getStatusColor(status);
          return PopupMenuItem<String>(
            value: status,
            height: 32, // Reduced height
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? Colors.grey[600]! : Colors.grey[400]!, 
            width: 1
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Remarks',
              style: TextStyle(
                color: isDark ? Colors.grey[300] : Colors.grey[700],
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              color: isDark ? Colors.grey[300] : Colors.grey[700],
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  // Updated color method with exact hex colors and better visibility for "Busy"
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Interested':
        return const Color(0xFF1FB529); // #1FB529
      case 'RNR':
        return const Color(0xFFD82D1A); // #D82D1A
      case 'Busy':
        return const Color(0xFFE67E22); // Using darker orange for better visibility
      case 'Contact again':
        return const Color(0xFF407BFF); // #407BFF
      case 'Pending':
        return Colors.purple;
      case 'Switched off':
        return Colors.grey;
      case 'Not Interested':
        return const Color(0xFFD82D1A);
      case 'Not Suitable':
        return const Color(0xFFD82D1A);
      case 'Wrong Number':
        return const Color(0xFFD82D1A);
      default:
        return Colors.grey;
    }
  }

  Future<void> _launchWhatsAppWithMessage(String phone, String message) async {
    final Uri whatsappUri = Uri.parse("https://wa.me/$phone?text=${Uri.encodeComponent(message)}");
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri);
    }
  }

  Future<void> _launchPhone(String phone) async {
    final Uri phoneUri = Uri.parse("tel:$phone");
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  Future<void> _launchSMSWithMessage(String phone, String message) async {
    final Uri smsUri = Uri.parse("sms:$phone?body=${Uri.encodeComponent(message)}");
    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    }
  }

  Future<void> _launchEmailWithMessage(String email, String message) async {
    final Uri emailUri = Uri.parse("mailto:$email?subject=Job Opportunity&body=${Uri.encodeComponent(message)}");
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  void _scheduleCall() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Schedule Call'),
        content: const Text('Call scheduling feature coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text, bool isDark) {
    return Row(
      children: [
        Icon(
          icon, 
          size: 16, 
          color: isDark ? Colors.grey[400] : Colors.grey[600]
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[300] : Colors.grey[700],
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// Candidate Model
class CandidateModel {
  final String name;
  final String location;
  final String qualification;
  final String languages;
  final String experience;
  final String gender;
  String status;
  Color statusColor;
  final String role;
  final String uploadDate;
  final String phone;
  final String email;
  bool isUnlocked;

  CandidateModel({
    required this.name,
    required this.location,
    required this.qualification,
    required this.languages,
    required this.experience,
    required this.gender,
    required this.status,
    required this.statusColor,
    required this.role,
    required this.uploadDate,
    required this.phone,
    required this.email,
    required this.isUnlocked,
  });
}

// Unlocked Candidate Detail Page
class UnlockedCandidateDetailPage extends StatefulWidget {
  final CandidateModel candidate;
  final VoidCallback? onBack;

  final int databaseCount;
  final int unlockedCount;

  const UnlockedCandidateDetailPage({
    super.key, 
    required this.candidate,
    this.onBack,
    required this.databaseCount,
    required this.unlockedCount,
  });

  @override
  State<UnlockedCandidateDetailPage> createState() => _UnlockedCandidateDetailPageState();
}

class _UnlockedCandidateDetailPageState extends State<UnlockedCandidateDetailPage> {
  String selectedCallStatus = 'Interested';

  @override
  void initState() {
    super.initState();
    selectedCallStatus = widget.candidate.status;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF181A20) : const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF23262B) : Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Text(
              'Data Vault',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[700] : Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '(${widget.databaseCount},${widget.unlockedCount})',
                style: TextStyle(
                  color: isDark ? Colors.grey[300] : Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: Icon(
              Icons.add, 
              color: isDark ? Colors.grey[300] : Colors.grey[600]
            ),
          ),
          Icon(
            Icons.menu, 
            color: isDark ? Colors.grey[300] : Colors.grey[600]
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tab Section - Fixed at top
          Container(
            color: isDark ? const Color(0xFF23262B) : Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    if (widget.onBack != null) {
                      widget.onBack!();
                    }
                  },
                  child: _buildTab('Database', '(${widget.databaseCount})', false, isDark),
                ),
                const SizedBox(width: 16),
                _buildTab('Unlocked', '(${widget.unlockedCount})', true, isDark),
              ],
            ),
          ),
          
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Candidate Details Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF23262B) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: isDark 
                              ? Colors.black.withOpacity(0.3)
                              : Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with name and role
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.candidate.name,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? Colors.white : Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.candidate.location,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDark ? Colors.grey[300] : Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.green[100],
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                widget.candidate.role,
                                style: TextStyle(
                                  color: Colors.green[700],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Edit'),
                                    content: const Text('Edit feature coming soon!'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: Icon(
                                Icons.edit,
                                color: isDark ? Colors.grey[500] : Colors.grey[400],
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Details rows
                        Row(
                          children: [
                            Expanded(
                              child: _buildDetailRow(Icons.school, widget.candidate.qualification, isDark),
                            ),
                            Expanded(
                              child: _buildDetailRow(Icons.language, widget.candidate.languages, isDark),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildDetailRow(Icons.work, widget.candidate.experience, isDark),
                            ),
                            Expanded(
                              child: _buildDetailRow(Icons.person, widget.candidate.gender, isDark),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        // Communication Options
                        Row(
                          children: [
                            Expanded(
                              child: _buildExactScreenshotButton(
                                icon: FontAwesomeIcons.whatsapp,
                                label: 'WhatsApp',
                                color: const Color(0xFF25D366),
                                onTap: () => _launchWhatsAppWithMessage(
                                  widget.candidate.phone,
                                  'Hi,\nI have a job vacancy in your city.\n\nJob Details:\nJob: Sales executive\nSalary: up to Rs.35,000\nCall Me: 9818074659',
                                ),
                                isDark: isDark,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildExactScreenshotButton(
                                icon: Icons.phone_outlined,
                                label: 'Phone',
                                color: const Color(0xFF2196F3),
                                onTap: () => _launchPhone(widget.candidate.phone),
                                isDark: isDark,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildExactScreenshotButton(
                                icon: Icons.schedule_outlined,
                                label: 'Schedule',
                                color: const Color(0xFF9C27B0),
                                onTap: () => _scheduleCall(),
                                isDark: isDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _buildExactScreenshotButton(
                                icon: Icons.sms_outlined,
                                label: 'SMS',
                                color: const Color(0xFFFF9800),
                                onTap: () => _launchSMSWithMessage(
                                  widget.candidate.phone,
                                  'Hi,\nI have a job vacancy in your city.\n\nJob: Sales executive\nSalary: up to Rs.35,000\nCall Me: 9818074659',
                                ),
                                isDark: isDark,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildExactScreenshotButton(
                                icon: Icons.email_outlined,
                                label: 'Email',
                                color: const Color(0xFFF44336),
                                onTap: () => _launchEmailWithMessage(
                                  widget.candidate.email,
                                  'Dear Candidate,\n\nI hope this email finds you well.\n\nI have a job vacancy in your city.\n\nJob Details:\nPosition: Sales executive\nSalary: up to Rs.35,000\nContact: 9818074659\n\nBest regards',
                                ),
                                isDark: isDark,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildRemarksDropdown(widget.candidate, isDark),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        // Call Status
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(selectedCallStatus).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: _getStatusColor(selectedCallStatus).withOpacity(0.3)),
                              ),
                              child: Text(
                                selectedCallStatus,
                                style: TextStyle(
                                  color: _getStatusColor(selectedCallStatus),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        Text(
                          'Uploaded date\n${widget.candidate.uploadDate}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey[400] : Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // WhatsApp Dialog for Detail Page
  void _showWhatsAppDialog(CandidateModel candidate) {
    final TextEditingController messageController = TextEditingController();
    messageController.text = '''Hi,
I have a job vacancy in your city.

Job Details:
Job: Sales executive
Salary: up to Rs.35,000
Call Me: 9818074659''';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Dialog(
          backgroundColor: isDark ? const Color(0xFF23262B) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Send Whatsapp',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Message',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2A2D32) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: messageController,
                    maxLines: 6,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(12),
                      hintText: 'Enter your message...',
                      hintStyle: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: isDark ? Colors.grey[300] : Colors.grey[600],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _launchWhatsAppWithMessage(candidate.phone, messageController.text);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Send'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // SMS Dialog for Detail Page
  void _showSMSDialog(CandidateModel candidate) {
    final TextEditingController messageController = TextEditingController();
    messageController.text = '''Hi,
I have a job vacancy in your city.

Job: Sales executive
Salary: up to Rs.35,000
Call Me: 9818074659''';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Dialog(
          backgroundColor: isDark ? const Color(0xFF23262B) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Send Sms',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Message',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2A2D32) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: messageController,
                    maxLines: 5,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(12),
                      hintText: 'Enter your message...',
                      hintStyle: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: isDark ? Colors.grey[300] : Colors.grey[600],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _launchSMSWithMessage(candidate.phone, messageController.text);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Send'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Email Dialog for Detail Page
  void _showEmailDialog(CandidateModel candidate) {
    final TextEditingController messageController = TextEditingController();
    messageController.text = '''Dear Candidate,

I hope this email finds you well.

I have a job vacancy in your city.

Job Details:
Position: Sales executive
Salary: up to Rs.35,000
Contact: 9818074659

Best regards''';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Dialog(
          backgroundColor: isDark ? const Color(0xFF23262B) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Send Email',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Message',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2A2D32) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: messageController,
                    maxLines: 8,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(12),
                      hintText: 'Enter your message...',
                      hintStyle: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: isDark ? Colors.grey[300] : Colors.grey[600],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _launchEmailWithMessage(candidate.email, messageController.text);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Send'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTab(String title, String count, bool isSelected, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected 
            ? (isDark ? primaryBlue.withOpacity(0.2) : Colors.blue[100])
            : (isDark ? Colors.grey[800] : Colors.grey[200]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isSelected 
                  ? (isDark ? primaryBlue : Colors.blue[700])
                  : (isDark ? Colors.grey[300] : Colors.grey[600]),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            count,
            style: TextStyle(
              color: isSelected 
                  ? (isDark ? primaryBlue : Colors.blue[700])
                  : (isDark ? Colors.grey[300] : Colors.grey[600]),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text, bool isDark) {
    return Row(
      children: [
        Icon(
          icon, 
          size: 16, 
          color: isDark ? Colors.grey[400] : Colors.grey[600]
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[300] : Colors.grey[700],
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildExactScreenshotButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // CORRECTED: Dropdown with proper positioning and reduced gaps for detail page
  Widget _buildRemarksDropdown(CandidateModel candidate, bool isDark) {
    final List<String> statusOptions = [
      'Interested',
      'RNR',
      'Busy',
      'Contact again',
      'Pending',
      'Switched off',
    ];

    return PopupMenuButton<String>(
      offset: const Offset(0, 40), // Position dropdown below the button
      onSelected: (String? newValue) {
        if (newValue != null) {
          setState(() {
            candidate.status = newValue;
            candidate.statusColor = _getStatusColor(newValue);
            selectedCallStatus = newValue;
          });
        }
      },
      itemBuilder: (BuildContext context) => [
        // Header item (non-selectable)
        PopupMenuItem<String>(
          enabled: false,
          height: 32, // Reduced height
          child: Text(
            'Call Status',
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        // Divider with reduced space
        const PopupMenuDivider(height: 8),
        // Status options with reduced height
        ...statusOptions.map((String status) {
          Color statusColor = _getStatusColor(status);
          return PopupMenuItem<String>(
            value: status,
            height: 32, // Reduced height
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? Colors.grey[600]! : Colors.grey[400]!, 
            width: 1
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Remarks',
              style: TextStyle(
                color: isDark ? Colors.grey[300] : Colors.grey[700],
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              color: isDark ? Colors.grey[300] : Colors.grey[700],
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  // Updated color method with exact hex colors and better visibility for "Busy"
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Interested':
        return const Color(0xFF1FB529); // #1FB529
      case 'RNR':
        return const Color(0xFFD82D1A); // #D82D1A
      case 'Busy':
        return const Color(0xFFE67E22); // Using darker orange for better visibility
      case 'Contact again':
        return const Color(0xFF407BFF); // #407BFF
      case 'Pending':
        return Colors.purple;
      case 'Switched off':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  Future<void> _launchWhatsAppWithMessage(String phone, String message) async {
    final Uri whatsappUri = Uri.parse("https://wa.me/$phone?text=${Uri.encodeComponent(message)}");
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri);
    }
  }

  Future<void> _launchPhone(String phone) async {
    final Uri phoneUri = Uri.parse("tel:$phone");
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  Future<void> _launchSMSWithMessage(String phone, String message) async {
    final Uri smsUri = Uri.parse("sms:$phone?body=${Uri.encodeComponent(message)}");
    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    }
  }

  Future<void> _launchEmailWithMessage(String email, String message) async {
    final Uri emailUri = Uri.parse("mailto:$email?subject=Job Opportunity&body=${Uri.encodeComponent(message)}");
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  void _scheduleCall() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Schedule Call'),
        content: const Text('Call scheduling feature coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}