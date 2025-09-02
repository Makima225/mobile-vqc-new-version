import 'dart:convert';

class ActiviteGenerale {
  final int id;
  final String titre;
  final int sousProjetId;
  final List<int> qualiticientIds;

  ActiviteGenerale({
    required this.id,
    required this.titre,
    required this.sousProjetId,
    required this.qualiticientIds,
  });

  // 🔹 Convertir un JSON en instance de `ActiviteGenerale`
  factory ActiviteGenerale.fromJson(Map<String, dynamic> json) {
    return ActiviteGenerale(
      id: json['id'],
      titre: json['titre'],
      sousProjetId: json['sous_projet'],
      qualiticientIds: List<int>.from(json['qualiticient'] ?? []),
    );
  }

  // 🔹 Convertir une instance en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titre': titre,
      'sous_projet': sousProjetId,
      'qualiticient': qualiticientIds,
    };
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}