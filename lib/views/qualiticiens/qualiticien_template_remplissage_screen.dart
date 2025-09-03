import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/core/template_model.dart';
import '../../models/core/entete_model.dart';
import '../../services/core/entete_by_template_service.dart';
import '../../widgets/entete_card.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_state_widget.dart';

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

  @override
  void initState() {
    super.initState();
    _enteteService = EnteteByTemplateService.to; // Utiliser la dependency injection
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

    try {
      final entetes = await _enteteService.getEntetesByTemplate(template!.id!);
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

  void _onEnteteValueChanged(int enteteId, String value) {
    setState(() {
      _enteteValues[enteteId] = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Récupérer le template passé en argument
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

    return SingleChildScrollView(
      child: Column(
        children: [
          // Informations du template
          if (template != null) _buildTemplateInfo(template),
          
          // Card des entêtes
          EnteteCard(
            entetes: _entetes,
            enteteValues: _enteteValues,
            onValueChanged: _onEnteteValueChanged,
            primaryColor: QualiticiensTemplateRemplissageScreen.mainColor,
          ),

          // Espacement en bas
          const SizedBox(height: 80),
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
          Text(
            'Nom: ${template.nom}',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            'Type: ${template.typeDisplayName}',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            'ID: ${template.id ?? 'N/A'}',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
