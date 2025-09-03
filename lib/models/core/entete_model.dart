class Entete {
  final int? id;
  final String titre;
  final int? activiteSpecifique;
  final int? template;

  const Entete({
    this.id,
    required this.titre,
    this.activiteSpecifique,
    this.template,
  });

  /// Factory pour créer une instance depuis JSON
  factory Entete.fromJson(Map<String, dynamic> json) {
    return Entete(
      id: json['id'] as int?,
      titre: json['titre'] as String,
      activiteSpecifique: json['activite_specifique'] as int?,
      template: json['template'] as int?,
    );
  }

  /// Convertir en JSON pour l'API
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'titre': titre,
      if (activiteSpecifique != null) 'activite_specifique': activiteSpecifique,
      if (template != null) 'template': template,
    };
  }

  /// Créer une copie avec des valeurs modifiées
  Entete copyWith({
    int? id,
    String? titre,
    int? activiteSpecifique,
    int? template,
  }) {
    return Entete(
      id: id ?? this.id,
      titre: titre ?? this.titre,
      activiteSpecifique: activiteSpecifique ?? this.activiteSpecifique,
      template: template ?? this.template,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Entete &&
        other.id == id &&
        other.titre == titre &&
        other.activiteSpecifique == activiteSpecifique &&
        other.template == template;
  }

  @override
  int get hashCode {
    return Object.hash(id, titre, activiteSpecifique, template);
  }

  @override
  String toString() {
    return 'Entete{id: $id, titre: $titre, activiteSpecifique: $activiteSpecifique, template: $template}';
  }

  /// Validation
  bool get isValid {
    return titre.isNotEmpty;
  }
}
