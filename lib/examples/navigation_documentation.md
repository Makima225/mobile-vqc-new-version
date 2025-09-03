# Navigation des Activités Spécifiques vers les Templates

## Vue d'ensemble
Ce document explique comment la navigation fonctionne depuis les cartes d'activités spécifiques vers la page de gestion des templates.

## Flux de navigation

### 1. Point de départ : `qualiticien_activite_specifique_screen.dart`
- L'utilisateur clique sur une carte d'activité spécifique
- La fonction `_showActiviteSpecifiqueActions(activite)` est appelée
- Un bottom sheet s'affiche avec les options disponibles

### 2. Action de navigation
```dart
ListTile(
  leading: Icon(Icons.assignment_outlined, color: mainColor),
  title: const Text('Voir les templates'),
  onTap: () {
    Get.back(); // Ferme le bottom sheet
    Get.to(
      () => QualiticiensTemplateListScreen(),
      arguments: {
        'activiteSpecifiqueId': activite.id,
        'activiteSpecifiqueTitre': activite.titre,
      },
    );
  },
),
```

### 3. Page de destination : `qualiticien_template_list_screen.dart`
- Utilise le `TemplateController` pour gérer l'état
- Le controller récupère automatiquement les arguments de navigation dans `onInit()`

### 4. Traitement des arguments dans le controller
```dart
void _initializeFromArguments() {
  final arguments = Get.arguments;
  if (arguments != null && arguments is Map<String, dynamic>) {
    _selectedActiviteSpecifiqueId.value = arguments['activiteSpecifiqueId'];
    _selectedActiviteSpecifiqueTitre.value = arguments['activiteSpecifiqueTitre'] ?? '';
  }
}
```

### 5. Chargement automatique des données
```dart
Future<void> _loadInitialData() async {
  if (_selectedActiviteSpecifiqueId.value != null) {
    await fetchTemplatesByActiviteSpecifique(_selectedActiviteSpecifiqueId.value!);
  }
}
```

## Arguments passés

| Clé | Type | Description |
|-----|------|-------------|
| `activiteSpecifiqueId` | `int` | ID de l'activité spécifique sélectionnée |
| `activiteSpecifiqueTitre` | `String` | Titre de l'activité pour affichage dans l'AppBar |

## Interface utilisateur résultante

### AppBar dynamique
```dart
Text(
  _controller.selectedActiviteSpecifiqueId != null 
    ? 'Templates - ${_controller.selectedActiviteSpecifiqueTitre}'
    : 'Templates Fiche Contrôle',
  // ...
)
```

### Filtrage automatique
- Les templates sont automatiquement filtrés par l'ID de l'activité spécifique
- Seuls les templates liés à cette activité sont affichés
- Les statistiques sont calculées pour cette activité uniquement

## Exemple d'utilisation

```dart
// Navigation depuis n'importe où dans l'application
Get.to(
  () => QualiticiensTemplateListScreen(),
  arguments: {
    'activiteSpecifiqueId': 123,
    'activiteSpecifiqueTitre': 'Contrôle Qualité Produits',
  },
);
```

## Fonctionnalités disponibles sur la page des templates

1. **Visualisation des templates** : Liste filtrée par activité
2. **Recherche** : Recherche textuelle dans les templates
3. **Filtres** : Filtrage par type (PDF/DOCX)
4. **Statistiques** : Compteurs spécifiques à l'activité
5. **Actions CRUD** : Création, modification, suppression de templates
6. **Téléchargement** : Téléchargement des fichiers templates

## Notes techniques

- Utilise GetX pour la gestion d'état et la navigation
- Architecture MVVM avec séparation des responsabilités
- Gestion automatique des erreurs et des états de chargement
- Interface utilisateur responsive et moderne
- Support complet des opérations CRUD avec feedback utilisateur
