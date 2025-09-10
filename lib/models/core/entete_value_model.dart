class EnteteValue {
  final int id;
  final int entete;
  final String enteteTitre;  // Nouveau champ pour stocker "entete_titre"
  String valeur; // Modifiable par l'utilisateur

  EnteteValue({required this.id, required this.entete, required this.enteteTitre, required this.valeur});

  factory EnteteValue.fromJson(Map<String, dynamic> json) {
    return EnteteValue(
      id: json['id'],
      entete: json['entete'],
      enteteTitre: json['entete_titre'] ?? "",  // Récupère le titre de l'entête
      valeur: json['valeur']?.toString() ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "entete": entete,
      "entete_titre": enteteTitre,  // Inclure le titre dans la conversion en JSON
      "valeur": valeur,
    };
  }
}