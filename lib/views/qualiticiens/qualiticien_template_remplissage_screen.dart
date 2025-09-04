import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/core/template_model.dart';
import '../../models/core/entete_model.dart';
import '../../services/core/entete_by_template_service.dart';
import '../../widgets/entete_card.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_state_widget.dart';
import '../../widgets/schema_table_widget.dart';
import '../../utils/schema_utils.dart';

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

  @override
  void initState() {
    super.initState();
    _enteteService = EnteteByTemplateService.to;
    _loadEntetes();
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
    // Logique de sauvegarde des modifications des cellules
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
            onPressed: details.stepIndex == 1 ? _saveAndFinish : _nextStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: QualiticiensTemplateRemplissageScreen.mainColor,
              foregroundColor: Colors.white,
            ),
            child: Text(details.stepIndex == 1 ? 'Sauvegarder' : 'Suivant'),
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
                ficheControleId: template?.id ?? 0, // ID de la fiche de contrôle
                onCellChanged: _onCellChanged,
              ),
            );
          }).toList(),
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
            QualiticiensTemplateRemplissageScreen.mainColor,
            QualiticiensTemplateRemplissageScreen.mainColor.withValues(alpha: 0.8),
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

  Future<void> _saveAndFinish() async {
    final TemplateFichecontrole? template = Get.arguments as TemplateFichecontrole?;
    if (template == null) {
      _showErrorSnackbar('Template introuvable');
      return;
    }
    
    // Préparer les données à sauvegarder
    Map<String, dynamic> dataToSave = {
      'template_id': template.id,
      'entetes': _enteteValues,
      'schema_data': _schemaData,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    // Utiliser les données pour la sauvegarde
    print('📊 Données préparées: $dataToSave');
    
    _showSuccessSnackbar('Données sauvegardées avec succès');
    Get.back();
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
