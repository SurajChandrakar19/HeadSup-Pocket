import 'package:flutter/material.dart';

class EditCandidatePopup extends StatefulWidget {
  final Map<String, dynamic> candidate;
  final void Function(Map<String, dynamic> updatedCandidate) onSave;

  const EditCandidatePopup({
    super.key,
    required this.candidate,
    required this.onSave,
  });

  @override
  State<EditCandidatePopup> createState() => _EditCandidatePopupState();
}

class _EditCandidatePopupState extends State<EditCandidatePopup> {
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController roleController;
  late TextEditingController locationController;
  late TextEditingController qualificationController;
  late TextEditingController experienceController;
  late TextEditingController ageController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.candidate['name'] ?? '');
    phoneController = TextEditingController(text: widget.candidate['phone'] ?? '');
    roleController = TextEditingController(text: widget.candidate['role'] ?? '');
    locationController = TextEditingController(text: widget.candidate['location'] ?? '');
    qualificationController = TextEditingController(text: widget.candidate['qualification'] ?? '');
    experienceController = TextEditingController(text: widget.candidate['experience'] ?? '');
    ageController = TextEditingController(text: widget.candidate['age']?.toString() ?? '');
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    roleController.dispose();
    locationController.dispose();
    qualificationController.dispose();
    experienceController.dispose();
    ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      backgroundColor: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.edit, color: Theme.of(context).colorScheme.primary, size: 28),
                  const SizedBox(width: 10),
                  Text(
                    'Edit Candidate',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _styledTextField(context, nameController, 'Name', Icons.person),
              const SizedBox(height: 14),
              _styledTextField(context, phoneController, 'Phone', Icons.phone, keyboardType: TextInputType.phone),
              const SizedBox(height: 14),
              _styledTextField(context, roleController, 'Role', Icons.work),
              const SizedBox(height: 14),
              _styledTextField(context, locationController, 'Location', Icons.location_on),
              const SizedBox(height: 14),
              _styledTextField(context, qualificationController, 'Qualification', Icons.school),
              const SizedBox(height: 14),
              _styledTextField(context, experienceController, 'Experience', Icons.timeline),
              const SizedBox(height: 14),
              _styledTextField(context, ageController, 'Age', Icons.cake, keyboardType: TextInputType.number),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).textTheme.bodyMedium?.color,
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      final updatedCandidate = Map<String, dynamic>.from(widget.candidate);
                      updatedCandidate['name'] = nameController.text;
                      updatedCandidate['phone'] = phoneController.text;
                      updatedCandidate['role'] = roleController.text;
                      updatedCandidate['location'] = locationController.text;
                      updatedCandidate['qualification'] = qualificationController.text;
                      updatedCandidate['experience'] = experienceController.text;
                      updatedCandidate['age'] = int.tryParse(ageController.text) ?? widget.candidate['age'];
                      widget.onSave(updatedCandidate);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                    ),
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _styledTextField(BuildContext context, TextEditingController controller, String label, IconData icon, {TextInputType keyboardType = TextInputType.text}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: Theme.of(context).textTheme.bodyMedium,
        prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.primary),
        filled: true,
        fillColor: isDark ? Colors.white10 : Colors.blue.withOpacity(0.06),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
    );
  }
}

