import 'package:flutter/material.dart';
import '../data/companies_data.dart';
import '../models/company_model.dart';

class ReschedulePopupForm extends StatefulWidget {
  final String initialPhone;
  final String? initialName;
  final String? initialRole;
  final String? initialLocation;
  final String? initialQualification;
  final String? initialExperience;
  final String? initialInterviewTime;
  final String? initialCompany;
  final bool onlyEditTime;
  final void Function(Map<String, dynamic> candidateData) onBookInterview;
  final VoidCallback? onCompanyAdded;
  final String userId;

  const ReschedulePopupForm({
    super.key,
    required this.initialPhone,
    this.initialName,
    this.initialRole,
    this.initialLocation,
    this.initialQualification,
    this.initialExperience,
    this.initialInterviewTime,
    this.initialCompany,
    this.onlyEditTime = false,
    required this.onBookInterview,
    this.onCompanyAdded,
    required this.userId,
  });

  @override
  State<ReschedulePopupForm> createState() => _ReschedulePopupFormState();
}

class _ReschedulePopupFormState extends State<ReschedulePopupForm> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  Company? selectedCompany;

  @override
  void initState() {
    super.initState();
    // Pre-fill selectedCompany by matching initialCompany name
    if (widget.initialCompany != null && widget.initialCompany!.isNotEmpty) {
      if (globalCompanies.isNotEmpty) {
        selectedCompany = globalCompanies.firstWhere(
          (c) => c.name == widget.initialCompany,
          orElse: () => globalCompanies[0],
        );
      } else {
        selectedCompany = null;
      }
    }
    if (widget.initialInterviewTime != null && widget.initialInterviewTime!.isNotEmpty) {
      final dateTimeParts = widget.initialInterviewTime!.split(' ');
      if (dateTimeParts.length == 2) {
        final dateParts = dateTimeParts[0].split('-');
        final timeParts = dateTimeParts[1].split(':');
        if (dateParts.length == 3 && timeParts.length >= 2) {
          selectedDate = DateTime(
            int.parse(dateParts[0]),
            int.parse(dateParts[1]),
            int.parse(dateParts[2]),
          );
          selectedTime = TimeOfDay(
            hour: int.parse(timeParts[0]),
            minute: int.parse(timeParts[1]),
          );
        }
      }
    }
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
              primary: Colors.green,
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
        selectedTime = null;
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
              primary: Colors.green,
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
      });
    }
  }

  void _submit() {
    if (selectedDate == null || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select date and time'),
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
    widget.onBookInterview({
      'interviewTime':
          '${interviewDateTime.year}-${interviewDateTime.month.toString().padLeft(2, '0')}-${interviewDateTime.day.toString().padLeft(2, '0')} '
          '${interviewDateTime.hour.toString().padLeft(2, '0')}:${interviewDateTime.minute.toString().padLeft(2, '0')}',
    });
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextFormField(
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        enabled: false,
        style: const TextStyle(color: Colors.black87),
      ),
    );
  }

  String _getWeekdayName(int weekday) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdays[weekday - 1];
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
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
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFFBE9B7),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Reschedule Interview',
                  style: TextStyle(
                    color: Color(0xFF726E02),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Color(0xFF726E02)),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildReadOnlyField('First Name', widget.initialName?.split(' ').first ?? ''),
                  _buildReadOnlyField('Last Name', widget.initialName?.split(' ').skip(1).join(' ') ?? ''),
                  _buildReadOnlyField('Mobile Number', widget.initialPhone),
                  _buildReadOnlyField('Experience', widget.initialExperience ?? ''),
                  _buildReadOnlyField('Locality', widget.initialLocation ?? ''),
                  _buildReadOnlyField('Job Category', widget.initialRole ?? ''),
                  _buildReadOnlyField('Qualification', widget.initialQualification ?? ''),
                  // Company Dropdown (matches CandidatePopupForm)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: DropdownButtonFormField<Company>(
                      value: selectedCompany,
                      items: globalCompanies.map((company) {
                        return DropdownMenuItem<Company>(
                          value: company,
                          child: Text(company.name),
                        );
                      }).toList(),
                      onChanged: (Company? selected) {
                        if (selected != null) {
                          setState(() {
                            selectedCompany = selected;
                          });
                        }
                      },
                      decoration: InputDecoration(
                        labelText: 'Company',
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        hintText: selectedCompany == null ? 'Select a company' : null,
                      ),
                      icon: const Icon(Icons.arrow_drop_down),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Select New Interview Date and Time',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _selectDate,
                            borderRadius: BorderRadius.circular(8),
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
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFBE9B7),
                  foregroundColor: const Color(0xFF726E02),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'RESCHEDULE',
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
