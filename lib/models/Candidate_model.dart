class Candidate {
  final int id;
  final String name;
  final String role;
  final String location;
  final String qualification;
  final String experience;
  final int age;
  final String phone;
  final double rating;
  final String addedDate;
  final String notes;
  final String interviewTime;

  Candidate({
    required this.id,
    required this.name,
    required this.role,
    required this.location,
    required this.qualification,
    required this.experience,
    required this.age,
    required this.phone,
    required this.rating,
    required this.addedDate,
    required this.notes,
    required this.interviewTime,
  });

  factory Candidate.fromJson(Map<String, dynamic> json) {
    return Candidate(
      id: json['id'],
      name: json['name'],
      role: json['role'],
      location: json['location'],
      qualification: json['qualification'],
      experience: json['experience'],
      age: json['age'],
      phone: json['phone'],
      rating: json['rating'].toDouble(),
      addedDate: json['addedDate'],
      notes: json['notes'],
      interviewTime: json['interviewTime'],
    );
  }
}
