import 'dart:convert';

class FicheControleRemplie {
  final int? id;
  final int activiteSpecifiqueId;
  final int? templateId;
  final String? nom;
  final Map<String, dynamic>? donnees;
  final String etatDeLaFiche; // 'En cours', 'Remplis', 'Validé'
  final int? qualiticientId;
  final String? signatureQualiticient; // chemin ou base64
  final DateTime? signatureQualiticientDate;
  final int? ingenieurTravauxId;
  final String? signatureIngenieurTravaux; // chemin ou base64
  final DateTime? signatureIngenieurTravauxDate;
  final String? photo; // chemin ou base64
  final DateTime? createdAt;
  final DateTime? updatedAt;

  FicheControleRemplie({
    this.id,
    required this.activiteSpecifiqueId,
    this.templateId,
    this.nom,
    this.donnees,
    required this.etatDeLaFiche,
    this.qualiticientId,
    this.signatureQualiticient,
    this.signatureQualiticientDate,
    this.ingenieurTravauxId,
    this.signatureIngenieurTravaux,
    this.signatureIngenieurTravauxDate,
    this.photo,
    this.createdAt,
    this.updatedAt,
  });

  factory FicheControleRemplie.fromJson(Map<String, dynamic> json) {
    return FicheControleRemplie(
      id: json['id'],
      activiteSpecifiqueId: json['activite_specifique'],
      templateId: json['template'],
      nom: json['nom'],
      donnees: json['donnees'] != null ? Map<String, dynamic>.from(json['donnees']) : null,
      etatDeLaFiche: json['etat_de_la_fiche'],
      qualiticientId: json['qualiticient'],
      signatureQualiticient: json['signature_qualiticient'],
      signatureQualiticientDate: json['signature_qualiticient_date'] != null
          ? DateTime.parse(json['signature_qualiticient_date'])
          : null,
      ingenieurTravauxId: json['ingenieur_travaux'],
      signatureIngenieurTravaux: json['signature_ingenieur_travaux'],
      signatureIngenieurTravauxDate: json['signature_ingenieur_travaux_date'] != null
          ? DateTime.parse(json['signature_ingenieur_travaux_date'])
          : null,
      photo: json['photo'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'activite_specifique': activiteSpecifiqueId,
      'template': templateId,
      'nom': nom,
      'donnees': donnees,
      'etat_de_la_fiche': etatDeLaFiche,
      'qualiticient': qualiticientId,
      'signature_qualiticient': signatureQualiticient,
      'signature_qualiticient_date': signatureQualiticientDate?.toIso8601String(),
      'ingenieur_travaux': ingenieurTravauxId,
      'signature_ingenieur_travaux': signatureIngenieurTravaux,
      'signature_ingenieur_travaux_date': signatureIngenieurTravauxDate?.toIso8601String(),
      'photo': photo,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
} 