class QualiticientDetails {
  final int id;
  final String name;
  final String surname;
  final String role;

  QualiticientDetails({
    required this.id,
    required this.name,
    required this.surname,
    required this.role,
  });

  factory QualiticientDetails.fromJson(Map<String, dynamic> json) {
    return QualiticientDetails(
      id: json['id'],
      name: json['name'],
      surname: json['surname'],
      role: json['role'] ?? 'Qualiticient',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'surname': surname,
      'role': role,
    };
  }
}