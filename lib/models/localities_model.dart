class Locality {
  final int id;
  final String name;

  Locality({required this.id, required this.name});

  factory Locality.fromJson(Map<String, dynamic> json) {
    return Locality(id: json['id'], name: json['name']);
  }
}
