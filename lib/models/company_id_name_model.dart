class CompanyIdName {
  final int id;
  final String companyName;

  CompanyIdName({required this.id, required this.companyName});

  factory CompanyIdName.fromJson(Map<String, dynamic> json) {
    return CompanyIdName(id: json['id'], companyName: json['name'] ?? json['companyName']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'companyName': companyName};
  }
}
