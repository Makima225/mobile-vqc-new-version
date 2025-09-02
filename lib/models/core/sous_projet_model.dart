import 'dart:convert';

class SousProjet {
  final int id;
  final String titre;
  final int projetId;

  SousProjet({
    required this.id,
    required this.titre,
    required this.projetId,
  });

  factory SousProjet.fromJson(Map<String, dynamic> json) {
    return SousProjet(
      id: json['id'],
      titre: json['titre'],
      projetId: json['projet'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titre': titre,
      'projet': projetId,
    };
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}