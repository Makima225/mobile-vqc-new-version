import 'dart:convert';

class ActiviteSpecifique {
  final int id;
  final String titre;
  final int activiteGeneraleId;

  ActiviteSpecifique({
    required this.id,
    required this.titre,
    required this.activiteGeneraleId,
  });

  factory ActiviteSpecifique.fromJson(Map<String, dynamic> json) {
    return ActiviteSpecifique(
      id: json['id'],
      titre: json['titre'],
      activiteGeneraleId: json['activite_generale'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titre': titre,
      'activite_generale': activiteGeneraleId,
    };
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}