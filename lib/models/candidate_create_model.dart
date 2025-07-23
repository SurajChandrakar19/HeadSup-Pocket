class CandidateCreateDTO {
  final String name;
  final String role;
  final String location;
  final String qualification;
  final String experience;
  final int age;
  final bool isActiveCandidate;
  final String phone;
  final String interviewTime; // formatted as 'yyyy-MM-dd HH:mm'
  final int userId;
  final int companyId;

  CandidateCreateDTO({
    required this.name,
    required this.role,
    required this.location,
    required this.qualification,
    required this.experience,
    required this.age,
    required this.isActiveCandidate,
    required this.phone,
    required this.interviewTime,
    required this.userId,
    required this.companyId,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'role': role,
      'location': location,
      'qualification': qualification,
      'experience': experience,
      'age': age,
      'isActiveCandidate': isActiveCandidate,
      'phone': phone,
      'interviewTime': interviewTime,
      'userId': userId,
      'companyId': companyId,
    };
  }
}
