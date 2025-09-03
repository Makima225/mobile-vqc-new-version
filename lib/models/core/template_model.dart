class TemplateFichecontrole {
  final int? id;
  final String nom;
  final int activiteSpecifiqueId;
  final String fichier;
  final TypeTemplate typeTemplate;
  final Map<String, dynamic>? schema;
  final int quantite;
  final int quantitemod;
  final DateTime createdAt;

  const TemplateFichecontrole({
    this.id,
    required this.nom,
    required this.activiteSpecifiqueId,
    required this.fichier,
    required this.typeTemplate,
    this.schema,
    this.quantite = 1,
    this.quantitemod = 0,
    required this.createdAt,
  });

  /// Factory pour créer une instance depuis JSON
  factory TemplateFichecontrole.fromJson(Map<String, dynamic> json) {
    return TemplateFichecontrole(
      id: json['id'] as int?,
      nom: json['nom'] as String,
      activiteSpecifiqueId: json['activite_specifique'] as int,
      fichier: json['fichier'] as String,
      typeTemplate: TypeTemplate.fromString(json['type_template'] as String),
      schema: json['schema'] as Map<String, dynamic>?,
      quantite: json['quantite'] as int? ?? 1,
      quantitemod: json['quantitemod'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convertir en JSON pour l'API
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nom': nom,
      'activite_specifique': activiteSpecifiqueId,
      'fichier': fichier,
      'type_template': typeTemplate.value,
      'schema': schema,
      'quantite': quantite,
      'quantitemod': quantitemod,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Créer une copie avec des modifications
  TemplateFichecontrole copyWith({
    int? id,
    String? nom,
    int? activiteSpecifiqueId,
    String? fichier,
    TypeTemplate? typeTemplate,
    Map<String, dynamic>? schema,
    int? quantite,
    int? quantitemod,
    DateTime? createdAt,
  }) {
    return TemplateFichecontrole(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      activiteSpecifiqueId: activiteSpecifiqueId ?? this.activiteSpecifiqueId,
      fichier: fichier ?? this.fichier,
      typeTemplate: typeTemplate ?? this.typeTemplate,
      schema: schema ?? this.schema,
      quantite: quantite ?? this.quantite,
      quantitemod: quantitemod ?? this.quantitemod,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TemplateFichecontrole &&
        other.id == id &&
        other.nom == nom &&
        other.activiteSpecifiqueId == activiteSpecifiqueId &&
        other.fichier == fichier &&
        other.typeTemplate == typeTemplate &&
        other.schema == schema &&
        other.quantite == quantite &&
        other.quantitemod == quantitemod &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      nom,
      activiteSpecifiqueId,
      fichier,
      typeTemplate,
      schema,
      quantite,
      quantitemod,
      createdAt,
    );
  }

  @override
  String toString() {
    return 'TemplateFichecontrole{'
        'id: $id, '
        'nom: $nom, '
        'activiteSpecifiqueId: $activiteSpecifiqueId, '
        'fichier: $fichier, '
        'typeTemplate: $typeTemplate, '
        'schema: $schema, '
        'quantite: $quantite, '
        'quantitemod: $quantitemod, '
        'createdAt: $createdAt'
        '}';
  }

  /// Getters utilitaires
  String get fichierUrl => fichier;
  String get typeDisplayName => typeTemplate.displayName;
  bool get hasSchema => schema != null && schema!.isNotEmpty;
  
  /// Validation
  bool get isValid {
    return nom.isNotEmpty && 
           activiteSpecifiqueId > 0 && 
           fichier.isNotEmpty &&
           quantite >= 0;
  }
}

/// Enum pour les types de template
enum TypeTemplate {
  pdf('pdf', 'PDF fillable'),
  docx('docx', 'DOCX');

  const TypeTemplate(this.value, this.displayName);

  final String value;
  final String displayName;

  /// Créer depuis une chaîne
  static TypeTemplate fromString(String value) {
    switch (value.toLowerCase()) {
      case 'pdf':
        return TypeTemplate.pdf;
      case 'docx':
        return TypeTemplate.docx;
      default:
        throw ArgumentError('Type de template non supporté: $value');
    }
  }

  /// Obtenir tous les types disponibles
  static List<TypeTemplate> get allTypes => TypeTemplate.values;

  /// Obtenir les types sous forme de Map pour les dropdowns
  static Map<String, String> get typesMap {
    return {
      for (var type in TypeTemplate.values) type.value: type.displayName
    };
  }

  @override
  String toString() => value;
}