import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/core/template_model.dart';
import '../../models/core/entete_model.dart';
import '../../services/core/entete_by_template_service.dart';
import '../../widgets/entete_card.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_state_widget.dart';
import '../../widgets/schema_table_widget.dart';
import '../../utils/schema_utils.dart';
import 'signature_screen.dart';

class QualiticiensTemplateRemplissageScreen extends StatefulWidget {
  static const Color mainColor = Colors.deepPurple;

  const QualiticiensTemplateRemplissageScreen({super.key});

  @override
  State<QualiticiensTemplateRemplissageScreen> createState() => 
      _QualiticiensTemplateRemplissageScreenState();
}

class _QualiticiensTemplateRemplissageScreenState 
    extends State<QualiticiensTemplateRemplissageScreen> {
  late EnteteByTemplateService _enteteService;
  
  List<Entete> _entetes = [];
  Map<int, String> _enteteValues = {};
  bool _isLoading = false;
  String? _errorMessage;
  
  int _currentStep = 0;
  Map<String, dynamic> _schemaData = {};
  
  // Gestion photo globale obligatoire
  final ImagePicker _picker = ImagePicker();
  File? _photoObligatoire;
  
  // Gestion des anomalies (optionnel)
  List<Map<String, dynamic>> _anomalies = [];
  
  // NOUVEAU: Timer pour éviter les sauvegardes trop fréquentes
  Timer? _saveTimer;
  Map<String, String> _pendingChanges = {};

  @override
  void initState() {
    super.initState();
    _enteteService = Get.find<EnteteByTemplateService>();
    _loadEntetes();
  }

  @override
  void dispose() {
    // Nettoyer le timer pour éviter les fuites mémoire
    _saveTimer?.cancel();
    super.dispose();
  }

  // Méthode pour prendre une photo obligatoire
  Future<void> _prendrePhotoObligatoire() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (photo != null) {
        setState(() {
          _photoObligatoire = File(photo.path);
        });
        _showSuccessSnackbar('Photo prise avec succès');
      }
    } catch (e) {
      _showErrorSnackbar('Erreur lors de la prise de photo: $e');
    }
  }

  // Méthode pour ajouter une anomalie
  void _ajouterAnomalie(Map<String, dynamic> anomalie) {
    setState(() {
      _anomalies.add(anomalie);
    });
  }

  // Callback pour recevoir les données du SchemaTableWidget
  void _onSchemaDataChanged(Map<String, dynamic> data) {
    setState(() {
      _schemaData = data;
    });
  }

  // Méthode pour synchroniser les données avant envoi
  void _synchronizeTableData() {
    print('🔄 Synchronisation des données de tableau...');
    
    // Synchroniser de 'elements' vers 'tables' pour être sûr
    if (_schemaData['elements'] is List && _schemaData['tables'] is List) {
      List elements = _schemaData['elements'];
      List tables = _schemaData['tables'];
      
      for (var element in elements) {
        if (element is Map && element['type'] == 'table' && element['rows'] is List) {
          // Trouver le tableau correspondant dans 'tables'
          for (var table in tables) {
            if (table is Map && table['rows'] is List) {
              List elementRows = element['rows'];
              List tableRows = table['rows'];
              
              // Synchroniser les valeurs
              for (int rowIndex = 0; rowIndex < elementRows.length && rowIndex < tableRows.length; rowIndex++) {
                if (elementRows[rowIndex] is List && tableRows[rowIndex] is List) {
                  List elementRow = elementRows[rowIndex];
                  List tableRow = tableRows[rowIndex];
                  
                  for (int colIndex = 0; colIndex < elementRow.length && colIndex < tableRow.length; colIndex++) {
                    if (elementRow[colIndex] is Map && elementRow[colIndex]['value'] != null) {
                      String newValue = elementRow[colIndex]['value'].toString();
                      if (tableRow[colIndex] != newValue) {
                        tableRow[colIndex] = newValue;
                        print('🔄 Sync: Row $rowIndex, Col $colIndex = "$newValue"');
                      }
                    }
                  }
                }
              }
              break; // Sortir après avoir trouvé le premier tableau
            }
          }
          break; // Sortir après avoir traité le premier élément table
        }
      }
    }
    
    print('✅ Synchronisation terminée');
  }

  Future<void> _loadEntetes() async {
    final TemplateFichecontrole? template = Get.arguments as TemplateFichecontrole?;
    
    if (template?.id == null) {
      setState(() {
        _errorMessage = 'Template invalide';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    _initializeTableFromSchema(template!);

    try {
      final entetes = await _enteteService.getEntetesByTemplate(template.id!);
      setState(() {
        _entetes = entetes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement des entêtes: $e';
        _isLoading = false;
      });
    }
  }

  void _initializeTableFromSchema(TemplateFichecontrole template) {
    if (template.schema == null) {
      _createDefaultSchema();
      return;
    }
    
    try {
      Map<String, dynamic> schema = Map<String, dynamic>.from(template.schema!);
      
      if (schema.isEmpty || (!schema.containsKey('elements') && !schema.containsKey('tables'))) {
        schema = SchemaUtils.createTestSchema();
      }
      
      if (!schema.containsKey('tables')) {
        SchemaUtils.convertLegacySchema(schema);
      }
      
      setState(() {
        _schemaData = schema;
      });
      
    } catch (e) {
      _createDefaultSchema();
    }
  }

  void _createDefaultSchema() {
    setState(() {
      _schemaData = {
        'tables': SchemaUtils.createDefaultTable()
      };
    });
  }

  void _onEnteteValueChanged(int enteteId, String value) {
    setState(() {
      _enteteValues[enteteId] = value;
    });
  }

  void _onCellChanged(int tableIndex, int rowIndex, int colIndex, String value) {
    // NOUVEAU: Système de debouncing pour éviter le verrouillage des champs
    print('🔄 Cell changed - Table: $tableIndex, Row: $rowIndex, Col: $colIndex, Value: "$value"');
    
    // Annuler le timer précédent s'il existe
    _saveTimer?.cancel();
    
    // Stocker temporairement les changements
    String cellKey = 'table_${tableIndex}_row_${rowIndex}_col_$colIndex';
    _pendingChanges[cellKey] = value;
    
    // Programmer la sauvegarde dans 500ms (quand l'utilisateur aura fini de taper)
    _saveTimer = Timer(const Duration(milliseconds: 500), () {
      _savePendingChanges();
    });
    
    // IMPORTANT: Pas de modification immédiate des données pour éviter la reconstruction
  }
  
  void _savePendingChanges() {
    print('💾 Sauvegarde des changements en attente...');
    
    // Initialiser la structure si nécessaire
    if (_schemaData['elements'] == null) {
      _schemaData['elements'] = [];
    }
    if (_schemaData['tables'] == null) {
      _schemaData['tables'] = [];
    }
    
    // Appliquer tous les changements en attente
    _pendingChanges.forEach((cellKey, value) {
      // Parser la clé pour extraire les indices
      RegExp regex = RegExp(r'table_(\d+)_row_(\d+)_col_(\d+)');
      Match? match = regex.firstMatch(cellKey);
      
      if (match != null) {
        int tableIndex = int.parse(match.group(1)!);
        int rowIndex = int.parse(match.group(2)!);
        int colIndex = int.parse(match.group(3)!);
        
        // Mettre à jour dans la section 'elements' (structure détaillée)
        if (_schemaData['elements'] is List) {
          List elements = _schemaData['elements'];
          
          for (var element in elements) {
            if (element is Map && element['type'] == 'table') {
              List? rows = element['rows'];
              if (rows != null && rowIndex < rows.length) {
                List? row = rows[rowIndex];
                if (row != null && colIndex < row.length) {
                  if (row[colIndex] is Map) {
                    row[colIndex]['value'] = value;
                    print('✅ Cellule mise à jour dans elements: ${row[colIndex]}');
                  }
                }
              }
              break;
            }
          }
        }
        
        // Mettre à jour dans la section 'tables' (structure simplifiée)
        if (_schemaData['tables'] is List) {
          List tables = _schemaData['tables'];
          if (tableIndex < tables.length && tables[tableIndex] is Map) {
            Map table = tables[tableIndex];
            if (table['rows'] is List) {
              List rows = table['rows'];
              if (rowIndex < rows.length && rows[rowIndex] is List) {
                List row = rows[rowIndex];
                if (colIndex < row.length) {
                  row[colIndex] = value;
                  print('✅ Cellule mise à jour dans tables: Row $rowIndex, Col $colIndex = "$value"');
                }
              }
            }
          }
        }
      }
    });
    
    // Nettoyer les changements en attente
    _pendingChanges.clear();
    print('✅ Sauvegarde terminée');
  }

  // NOUVEAU: Méthode pour recevoir et stocker les données d'anomalies
  void _onAnomalieAdded(Map<String, dynamic> anomalieData) {
    print('📝 Anomalie reçue: $anomalieData');
    
    // Ajouter l'anomalie à la liste des anomalies
    _anomalies.add(anomalieData);
    
    print('📋 Total anomalies enregistrées: ${_anomalies.length}');
    print('🗂️ Liste des anomalies: $_anomalies');
    
    // Optionnel: Afficher une confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Anomalie enregistrée (${_anomalies.length} au total)'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _nextStep() {
    if (_currentStep < 1) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final TemplateFichecontrole? template = Get.arguments as TemplateFichecontrole?;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          template?.nom ?? 'Remplissage Template',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: QualiticiensTemplateRemplissageScreen.mainColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadEntetes,
              tooltip: 'Actualiser les entêtes',
            ),
        ],
      ),
      body: _buildBody(template),
    );
  }

  Widget _buildBody(TemplateFichecontrole? template) {
    if (_isLoading) {
      return const LoadingWidget(message: 'Chargement des entêtes...');
    }

    if (_errorMessage != null) {
      return ErrorStateWidget(
        message: _errorMessage!,
        onRetry: _loadEntetes,
        primaryColor: QualiticiensTemplateRemplissageScreen.mainColor,
      );
    }

    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: Theme.of(context).colorScheme.copyWith(
          primary: QualiticiensTemplateRemplissageScreen.mainColor,
        ),
      ),
      child: Stepper(
        currentStep: _currentStep,
        onStepTapped: (step) => setState(() => _currentStep = step),
        controlsBuilder: _buildStepperControls,
        steps: [
          Step(
            title: const Text('Entêtes'),
            content: Column(
              children: [
                if (template != null) _buildTemplateInfo(template),
                EnteteCard(
                  entetes: _entetes,
                  enteteValues: _enteteValues,
                  onValueChanged: _onEnteteValueChanged,
                  primaryColor: QualiticiensTemplateRemplissageScreen.mainColor,
                ),
              ],
            ),
            isActive: _currentStep >= 0,
            state: _currentStep == 0 
                ? StepState.editing 
                : _enteteValues.isNotEmpty 
                    ? StepState.complete 
                    : StepState.disabled,
          ),
          Step(
            title: const Text('Tableaux Schema'),
            content: _buildSchemaStep(),
            isActive: _currentStep >= 1,
            state: _currentStep == 1 
                ? StepState.editing 
                : _schemaData.isNotEmpty 
                    ? StepState.complete 
                    : StepState.disabled,
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateInfo(TemplateFichecontrole template) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.description_outlined,
                color: QualiticiensTemplateRemplissageScreen.mainColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Informations du template',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: QualiticiensTemplateRemplissageScreen.mainColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('Nom: ${template.nom}', style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 4),
          Text('Type: ${template.typeDisplayName}', style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 4),
          Text('ID: ${template.id ?? 'N/A'}', style: const TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildStepperControls(BuildContext context, ControlsDetails details) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        children: [
          if (details.stepIndex > 0)
            OutlinedButton(
              onPressed: _previousStep,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: QualiticiensTemplateRemplissageScreen.mainColor),
              ),
              child: Text(
                'Précédent',
                style: TextStyle(color: QualiticiensTemplateRemplissageScreen.mainColor),
              ),
            ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: details.stepIndex == 1 ? _goToSignature : _nextStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: QualiticiensTemplateRemplissageScreen.mainColor,
              foregroundColor: Colors.white,
            ),
            child: Text(details.stepIndex == 1 ? 'Suivant' : 'Suivant'),
          ),
        ],
      ),
    );
  }

  Widget _buildSchemaStep() {
    final TemplateFichecontrole? template = Get.arguments as TemplateFichecontrole?;
    List<Map<String, dynamic>> tables = SchemaUtils.extractSimpleTables(_schemaData);
    
    if (tables.isEmpty) {
      return _buildEmptySchemaView();
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildSchemaHeader(),
          const SizedBox(height: 16),
          ...tables.asMap().entries.map((entry) {
            int tableIndex = entry.key;
            Map<String, dynamic> tableData = entry.value;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: SchemaTableWidget(
                tableData: tableData,
                tableIndex: tableIndex,
                ficheControleId: template?.id ?? 0,
                onCellChanged: _onCellChanged,
                onAnomalieAdded: _onAnomalieAdded,
              ),
            );
          }).toList(),
          const SizedBox(height: 24),
          _buildPhotoSection(),
        ],
      ),
    );
  }

  Widget _buildSchemaHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.deepPurple,
            Colors.deepPurple.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.table_chart_rounded, color: Colors.white, size: 24),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tableaux de données',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Remplissez les cellules selon le type de tableau',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade50,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.camera_alt, color: Colors.deepPurple),
              SizedBox(width: 8),
              Text(
                'Photo obligatoire',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_photoObligatoire != null) ...[
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  _photoObligatoire!,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Photo prise avec succès',
                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _prendrePhotoObligatoire,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Reprendre'),
                  style: TextButton.styleFrom(foregroundColor: Colors.orange),
                ),
              ],
            ),
          ] else ...[
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.red.shade300,
                  style: BorderStyle.solid,
                ),
                color: Colors.red.shade50,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt_outlined, 
                       size: 40, 
                       color: Colors.red.shade400),
                  const SizedBox(height: 8),
                  Text(
                    'Photo obligatoire requise',
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _prendrePhotoObligatoire,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Prendre une photo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptySchemaView() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[300]!),
      ),
      child: Column(
        children: [
          Icon(Icons.table_chart_outlined, size: 48, color: Colors.blue[600]),
          const SizedBox(height: 12),
          const Text(
            'Initialisation du tableau...',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.blue),
          ),
          const SizedBox(height: 8),
          const Text(
            'Un tableau par défaut va être créé pour vous permettre de commencer la saisie.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // NOUVEAU: Méthode pour réinitialiser le formulaire après envoi réussi
  void _resetFormAfterSuccess() {
    print('🔄 Réinitialisation du formulaire...');
    
    setState(() {
      // Réinitialiser les données de schéma
      _schemaData.clear();
      
      // Vider les changements en attente
      _pendingChanges.clear();
      
      // Annuler le timer en cours
      _saveTimer?.cancel();
      
      // Réinitialiser les entêtes
      _enteteValues.clear();
      
      // Supprimer la photo obligatoire
      _photoObligatoire = null;
      
      // Vider les anomalies
      _anomalies.clear();
      
      // Revenir au premier step
      _currentStep = 0;
    });
    
    // Recharger les entêtes pour un nouveau formulaire
    _loadEntetes();
    
    print('✅ Formulaire réinitialisé avec succès');
    
    // Afficher une confirmation
    Get.snackbar(
      'Succès',
      'Formulaire envoyé avec succès ! Prêt pour un nouveau remplissage.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green.shade100,
      colorText: Colors.green.shade800,
      icon: const Icon(Icons.check_circle, color: Colors.green),
      duration: const Duration(seconds: 3),
    );
  }

  Future<void> _goToSignature() async {
    // Récupérer le template depuis les arguments
    final TemplateFichecontrole? template = Get.arguments as TemplateFichecontrole?;
    
    if (template == null) {
      _showErrorSnackbar('Données du template introuvables');
      return;
    }
    
    // NOUVEAU: Synchroniser les données avant envoi
    _synchronizeTableData();
    
    // CORRECTION 1: Vérifier et logger l'ID de l'activité spécifique
    print('🔍 DÉBOGAGE activiteSpecifiqueId:');
    print('  Template ID: ${template.id}');
    print('  Template activiteSpecifiqueId: ${template.activiteSpecifiqueId}');
    
    // Utiliser l'activiteSpecifiqueId du template
    int activiteSpecifiqueId = template.activiteSpecifiqueId;
    
    // CORRECTION 2: Collecter les vraies données du tableau depuis les widgets
    print('🔍 DÉBOGAGE données tableau:');
    print('  Schema data après collecte: ${_schemaData.toString().substring(0, 500)}...');
    
    // Convertir _enteteValues (Map<int, String>) en Map<String, String>
    Map<String, String> enteteValuesString = {};
    _enteteValues.forEach((key, value) {
      enteteValuesString[key.toString()] = value;
    });
    
    print('📋 Redirection vers signature avec les données');
    print('  ✅ Template: ${template.nom}');
    print('  ✅ ActiviteSpecifiqueId: $activiteSpecifiqueId');
    print('  ✅ Entêtes: ${enteteValuesString.length} valeurs');
    print('  ✅ Photo: ${_photoObligatoire != null ? "Présente" : "Manquante"}');
    
    // Naviguer vers l'écran de signature avec tous les paramètres requis
    final result = await Get.to(() => SignatureScreen(
      template: template,
      activiteSpecifiqueId: activiteSpecifiqueId,
      enteteValues: enteteValuesString,
      schemaData: _schemaData,
      photoObligatoire: _photoObligatoire,
      anomalies: _anomalies,
    ));
    
    // NOUVEAU: Vérifier le résultat et réinitialiser si envoi réussi
    if (result == true) {
      // L'envoi a été réussi, réinitialiser le formulaire
      _resetFormAfterSuccess();
    }
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Erreur',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade100,
      colorText: Colors.red.shade800,
      icon: const Icon(Icons.error_outline, color: Colors.red),
    );
  }

  void _showSuccessSnackbar(String message) {
    Get.snackbar(
      'Succès',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade100,
      colorText: Colors.green.shade800,
      icon: const Icon(Icons.check_circle_outline, color: Colors.green),
    );
  }
}
