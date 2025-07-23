class Job {
  final String id;
  final String title;
  final String company;
  final String location;
  final String salary;
  final String type; // Full-Time, Remote, etc.
  final String description;
  final List<String> responsibilities;
  final String aboutCompany;
  final List<Job> similarJobs;

  Job({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.salary,
    required this.type,
    required this.description,
    required this.responsibilities,
    required this.aboutCompany,
    this.similarJobs = const [],
  });

  factory Job.fromMap(Map<String, dynamic> map) {
    return Job(
      id: map['id'].toString(),
      title: map['title'] ?? '',
      company: map['company'] ?? '',
      location: map['location'] ?? '',
      salary: map['salary'] ?? '',
      type: map['type'] ?? '',
      description: map['description'] ?? '',
      responsibilities: List<String>.from(map['responsibilities'] ?? []),
      aboutCompany: map['aboutCompany'] ?? '',
    );
  }
}
