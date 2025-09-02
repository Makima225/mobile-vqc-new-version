class UserModel {
  final String email;
  final String name;
  final String surname;
  final String role;
  final String picture;
  final String token;

  UserModel({
    required this.email,
    required this.name,
    required this.surname,
    required this.role,
    required this.picture,
    required this.token,
  });

  // ✅ Factory pour convertir un JSON en UserModel
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      surname: json['surname'] ?? '',
      role: json['role'] ?? '',
      picture: json['picture'] ?? '',
      token: json['access'] ?? '',
    );
  }

  // ✅ Convertir un objet UserModel en JSON (utile pour le stockage)
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'surname': surname,
      'role': role,
      'picture': picture,
      'access': token,
    };
  }
}