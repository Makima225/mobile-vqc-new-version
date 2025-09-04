class Anomalie {
  final int? id;
  final int ficheControleId;
  final String description;
  final String? photoUrl;
  final DateTime? dateSignalement;
  final int? signalePar;

  Anomalie({
    this.id,
    required this.ficheControleId,
    required this.description,
    this.photoUrl,
    this.dateSignalement,
    this.signalePar,
  });

  factory Anomalie.fromJson(Map<String, dynamic> json) {
    return Anomalie(
      id: json['id'],
      ficheControleId: json['fiche_controle'],
      description: json['description'],
      photoUrl: json['photo'],
      dateSignalement: json['date_signalement'] != null 
          ? DateTime.parse(json['date_signalement'])
          : null,
      signalePar: json['signale_par'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fiche_controle': ficheControleId,
      'description': description,
      'photo': photoUrl,
      'date_signalement': dateSignalement?.toIso8601String(),
      'signale_par': signalePar,
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'fiche_controle': ficheControleId,
      'description': description,
      // La photo sera gérée séparément via FormData
    };
  }
}
