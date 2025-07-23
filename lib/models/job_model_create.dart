class Job {
  final int? id;
  final String jobTitle;
  final String companyName;
  final String location;
  final String salary;
  final String jobType;
  final String description;
  final String aboutCompany;
  final int userId;
  final String userName;
  final DateTime addedAt;

  Job({
    required this.id,
    required this.jobTitle,
    required this.companyName,
    required this.location,
    required this.salary,
    required this.jobType,
    required this.description,
    required this.aboutCompany,
    required this.userId,
    required this.userName,
    required this.addedAt,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'],
      jobTitle: json['jobTitle'],
      companyName: json['companyName'],
      location: json['location'],
      salary: json['salary'],
      jobType: json['type'],
      description: json['description'],
      aboutCompany: json['aboutCompany'],
      userId: json['userId'],
      userName: json['userName'],
      addedAt: DateTime.parse(json['addedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'jobTitle': jobTitle,
      'companyName': companyName,
      'location': location,
      'salary': salary,
      'type': jobType,
      'description': description,
      'aboutCompany': aboutCompany,
      'userId': userId,
      'userName': userName,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toJsonCreate() => {
    "jobTitle": jobTitle,
    "companyName": companyName,
    "location": location,
    "salary": salary,
    "type": jobType, // Ensure it matches your API: FULL_TIME, etc.
    "description": description,
    "aboutCompany": aboutCompany,
    "userId": userId,
  };
}
