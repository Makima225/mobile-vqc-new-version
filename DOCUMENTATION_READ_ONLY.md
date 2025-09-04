/*
📋 DOCUMENTATION - Système Read-Only pour les colonnes pré-remplies

🎯 OBJECTIF :
Les colonnes qui contiennent déjà du texte (prédéfini dans le schéma) 
ne doivent PAS être modifiables - elles doivent être en lecture seule.

🔧 IMPLÉMENTATION :
Dans SchemaTableWidget, méthode _buildEditableCell :

1. VÉRIFICATION :
   bool isReadOnly = value.isNotEmpty && value.trim().isNotEmpty;

2. SI READ-ONLY → Affichage avec _buildReadOnlyCell() :
   - Fond gris clair (Colors.grey[100])
   - Icône de cadenas (Icons.lock_outline)
   - Texte en gris foncé
   - Bordure grise
   - NON MODIFIABLE

3. SI MODIFIABLE → Widgets d'édition normaux :
   - Dropdown si header contient "/"
   - Dropdown pour contrôle
   - TextField normal

📱 EXEMPLES D'UTILISATION :

TABLEAU EXEMPLE :
+------------------+------------------+------------------+
| Élément          | Critère          | Valeur mesurée   |
+------------------+------------------+------------------+
| [🔒] Mur extérieur| [🔒] Verticalité | [✏️] ___________  |
| [🔒] Fondations   | [🔒] Solidité    | [✏️] ___________  |
| [🔒] Toiture      | [🔒] Étanchéité  | [✏️] ___________  |
+------------------+------------------+------------------+

LÉGENDE :
[🔒] = Cellule en LECTURE SEULE (valeur prédéfinie)
[✏️] = Cellule MODIFIABLE (saisie utilisateur)

🎨 DESIGN READ-ONLY :
- Fond : Colors.grey[100]
- Icône : lock_outline (16px, gris)
- Texte : FontWeight.w500, gris foncé
- Bordure : Colors.grey[300]
- Comportement : Pas de focus, pas de saisie

✅ AVANTAGES :
- Protection des données prédéfinies
- Interface claire (visuel distinctif)
- UX intuitive (utilisateur comprend immédiatement)
- Saisie guidée (seules les bonnes colonnes sont modifiables)

⚠️ RÈGLE IMPORTANTE :
Si value.isNotEmpty && value.trim().isNotEmpty → READ-ONLY
Sinon → MODIFIABLE
*/
