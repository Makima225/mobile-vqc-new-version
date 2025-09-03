import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../services/core/template_by_activite_specifique_service.dart';
import '../../models/core/template_model.dart';

/// Controller optimisé pour la gestion des templates fiche contrôle
/// Gère les templates liés à une activité spécifique
/// Inclut les opérations CRUD complètes et la gestion d'état avancée
class TemplateController extends GetxController {
  // Services
  final TemplateFichecontroleByActiviteSpecifiqueService _templateService = Get.find<TemplateFichecontroleByActiviteSpecifiqueService>();

  // État des données
  final _templates = <TemplateFichecontrole>[].obs;
  final _isLoading = false.obs;
  final _errorMessage = ''.obs;
  final _hasError = false.obs;
  final _isCreating = false.obs;
  final _isUpdating = false.obs;
  final _isDeleting = false.obs;

  // État de sélection de l'activité spécifique
  final _selectedActiviteSpecifiqueId = Rx<int?>(null);
  final _selectedActiviteSpecifiqueTitre = ''.obs;

  // État du template sélectionné
  final _selectedTemplate = Rx<TemplateFichecontrole?>(null);

  // État de filtrage et recherche
  final _searchQuery = ''.obs;
  final _selectedTypeFilter = Rx<TypeTemplate?>(null);

  // Getters pour l'accès aux données
  List<TemplateFichecontrole> get templates => _templates;
  List<TemplateFichecontrole> get filteredTemplates => _getFilteredTemplates();
  bool get isLoading => _isLoading.value;
  bool get isCreating => _isCreating.value;
  bool get isUpdating => _isUpdating.value;
  bool get isDeleting => _isDeleting.value;
  bool get isPerformingAction => isCreating || isUpdating || isDeleting;
  String get errorMessage => _errorMessage.value;
  bool get hasError => _hasError.value;
  bool get hasData => _templates.isNotEmpty;
  bool get hasFilteredData => filteredTemplates.isNotEmpty;
  int? get selectedActiviteSpecifiqueId => _selectedActiviteSpecifiqueId.value;
  String get selectedActiviteSpecifiqueTitre => _selectedActiviteSpecifiqueTitre.value;
  TemplateFichecontrole? get selectedTemplate => _selectedTemplate.value;
  String get searchQuery => _searchQuery.value;
  TypeTemplate? get selectedTypeFilter => _selectedTypeFilter.value;

  // Statistiques
  int get totalTemplates => _templates.length;
  int get pdfTemplatesCount => _templates.where((t) => t.typeTemplate == TypeTemplate.pdf).length;
  int get docxTemplatesCount => _templates.where((t) => t.typeTemplate == TypeTemplate.docx).length;
  int get totalQuantity => _templates.fold(0, (sum, t) => sum + t.quantite);

  @override
  void onInit() {
    super.onInit();
    _initializeFromArguments();
    _loadInitialData();
  }

  /// Initialise les données à partir des arguments de navigation
  void _initializeFromArguments() {
    final arguments = Get.arguments;
    if (arguments != null && arguments is Map<String, dynamic>) {
      _selectedActiviteSpecifiqueId.value = arguments['activiteSpecifiqueId'];
      _selectedActiviteSpecifiqueTitre.value = arguments['activiteSpecifiqueTitre'] ?? '';
    }
  }

  /// Charge les données initiales
  Future<void> _loadInitialData() async {
    if (_selectedActiviteSpecifiqueId.value != null) {
      await fetchTemplatesByActiviteSpecifique(_selectedActiviteSpecifiqueId.value!);
    }
  }

  /// Récupère les templates pour une activité spécifique
  Future<void> fetchTemplatesByActiviteSpecifique(int activiteSpecifiqueId) async {
    try {
      _setLoadingState(true);
      _clearError();

      debugPrint('🔍 Récupération templates pour activité spécifique $activiteSpecifiqueId');
      
      final responseData = await _templateService.getTemplatesByActiviteSpecifique(activiteSpecifiqueId);
      
      debugPrint('📊 Données reçues du backend : ${responseData.length} templates');
      if (responseData.isNotEmpty) {
        debugPrint('📋 Premier template reçu : ${responseData.first}');
      }

      // Convertir les données en objets TemplateFichecontrole
      final List<TemplateFichecontrole> templates = responseData
          .map((json) => TemplateFichecontrole.fromJson(json as Map<String, dynamic>))
          .toList();

      _templates.assignAll(templates);

      // Vérifier si des données ont été récupérées
      if (_templates.isEmpty) {
        _setEmptyState();
      }

      debugPrint('✅ ${_templates.length} templates chargés pour l\'activité spécifique');

    } catch (e) {
      _handleError('Erreur lors de la récupération des templates', e);
    } finally {
      _setLoadingState(false);
    }
  }

  /// Crée un nouveau template
  Future<bool> createTemplate(TemplateFichecontrole template) async {
    try {
      _setCreatingState(true);
      _clearError();

      debugPrint('🔄 Création du template : ${template.nom}');

      final response = await _templateService.createTemplateFichecontrole(template.toJson());

      if (response != null) {
        final newTemplate = TemplateFichecontrole.fromJson(response);
        _templates.add(newTemplate);
        
        debugPrint('✅ Template créé avec succès : ${newTemplate.nom}');
        _showSuccessSnackbar('Template créé avec succès');
        return true;
      } else {
        _handleError('Erreur lors de la création du template', 'Réponse null du serveur');
        return false;
      }

    } catch (e) {
      _handleError('Erreur lors de la création du template', e);
      return false;
    } finally {
      _setCreatingState(false);
    }
  }

  /// Met à jour un template existant
  Future<bool> updateTemplate(TemplateFichecontrole template) async {
    if (template.id == null) {
      _handleError('Erreur de mise à jour', 'ID du template manquant');
      return false;
    }

    try {
      _setUpdatingState(true);
      _clearError();

      debugPrint('🔄 Mise à jour du template : ${template.nom}');

      final response = await _templateService.updateTemplateFichecontrole(
        template.id!,
        template.toJson(),
      );

      if (response != null) {
        final updatedTemplate = TemplateFichecontrole.fromJson(response);
        final index = _templates.indexWhere((t) => t.id == template.id);
        
        if (index != -1) {
          _templates[index] = updatedTemplate;
        }

        // Mettre à jour le template sélectionné si c'est le même
        if (_selectedTemplate.value?.id == template.id) {
          _selectedTemplate.value = updatedTemplate;
        }
        
        debugPrint('✅ Template mis à jour avec succès : ${updatedTemplate.nom}');
        _showSuccessSnackbar('Template mis à jour avec succès');
        return true;
      } else {
        _handleError('Erreur lors de la mise à jour du template', 'Réponse null du serveur');
        return false;
      }

    } catch (e) {
      _handleError('Erreur lors de la mise à jour du template', e);
      return false;
    } finally {
      _setUpdatingState(false);
    }
  }

  /// Supprime un template
  Future<bool> deleteTemplate(int templateId) async {
    try {
      _setDeletingState(true);
      _clearError();

      debugPrint('🔄 Suppression du template ID: $templateId');

      final success = await _templateService.deleteTemplateFichecontrole(templateId);

      if (success) {
        _templates.removeWhere((t) => t.id == templateId);
        
        // Désélectionner si c'était le template sélectionné
        if (_selectedTemplate.value?.id == templateId) {
          _selectedTemplate.value = null;
        }
        
        debugPrint('✅ Template supprimé avec succès');
        _showSuccessSnackbar('Template supprimé avec succès');
        return true;
      } else {
        _handleError('Erreur lors de la suppression du template', 'Opération échouée');
        return false;
      }

    } catch (e) {
      _handleError('Erreur lors de la suppression du template', e);
      return false;
    } finally {
      _setDeletingState(false);
    }
  }

  /// Récupère un template spécifique par son ID
  Future<TemplateFichecontrole?> getTemplateById(int templateId) async {
    try {
      _clearError();

      debugPrint('🔍 Récupération du template ID: $templateId');

      final response = await _templateService.getTemplateFichecontroleById(templateId);

      if (response != null) {
        final template = TemplateFichecontrole.fromJson(response);
        _selectedTemplate.value = template;
        
        debugPrint('✅ Template récupéré : ${template.nom}');
        return template;
      } else {
        _handleError('Template non trouvé', 'Template avec ID $templateId introuvable');
        return null;
      }

    } catch (e) {
      _handleError('Erreur lors de la récupération du template', e);
      return null;
    }
  }

  /// Télécharge un fichier template
  Future<bool> downloadTemplate(TemplateFichecontrole template) async {
    try {
      _clearError();

      debugPrint('📥 Téléchargement du template : ${template.nom}');

      final response = await _templateService.downloadTemplateFichier(template.fichier);

      if (response != null && response.statusCode == 200) {
        debugPrint('✅ Template téléchargé avec succès');
        _showSuccessSnackbar('Template téléchargé avec succès');
        return true;
      } else {
        _handleError('Erreur de téléchargement', 'Impossible de télécharger le fichier');
        return false;
      }

    } catch (e) {
      _handleError('Erreur lors du téléchargement', e);
      return false;
    }
  }

  /// Rafraîchit les données
  Future<void> refreshTemplates() async {
    _clearError();
    if (_selectedActiviteSpecifiqueId.value != null) {
      await fetchTemplatesByActiviteSpecifique(_selectedActiviteSpecifiqueId.value!);
    }
  }

  /// Sélectionne un template
  void selectTemplate(TemplateFichecontrole template) {
    _selectedTemplate.value = template;
    debugPrint('📌 Template sélectionné : ${template.nom}');
  }

  /// Désélectionne le template actuel
  void clearSelection() {
    _selectedTemplate.value = null;
    debugPrint('🔄 Sélection de template effacée');
  }

  /// Met à jour la requête de recherche
  void updateSearchQuery(String query) {
    _searchQuery.value = query.toLowerCase();
    debugPrint('🔍 Recherche mise à jour : $query');
  }

  /// Met à jour le filtre de type
  void updateTypeFilter(TypeTemplate? type) {
    _selectedTypeFilter.value = type;
    debugPrint('🔧 Filtre de type mis à jour : ${type?.displayName ?? 'Tous'}');
  }

  /// Efface tous les filtres
  void clearFilters() {
    _searchQuery.value = '';
    _selectedTypeFilter.value = null;
    debugPrint('🔄 Filtres effacés');
  }

  /// Vérifie la disponibilité des templates
  Future<bool> checkTemplateAvailability() async {
    if (_selectedActiviteSpecifiqueId.value == null) return false;
    return await _templateService.isTemplateAvailable(_selectedActiviteSpecifiqueId.value!);
  }

  /// Obtient le nombre de templates
  Future<int> getTemplateCount() async {
    if (_selectedActiviteSpecifiqueId.value == null) return 0;
    return await _templateService.countTemplatesByActiviteSpecifique(_selectedActiviteSpecifiqueId.value!);
  }

  /// Filtre les templates selon les critères actuels
  List<TemplateFichecontrole> _getFilteredTemplates() {
    List<TemplateFichecontrole> filtered = List.from(_templates);

    // Filtre par recherche
    if (_searchQuery.value.isNotEmpty) {
      filtered = filtered.where((template) =>
          template.nom.toLowerCase().contains(_searchQuery.value)).toList();
    }

    // Filtre par type
    if (_selectedTypeFilter.value != null) {
      filtered = filtered.where((template) =>
          template.typeTemplate == _selectedTypeFilter.value).toList();
    }

    return filtered;
  }

  /// Met à jour l'état de chargement
  void _setLoadingState(bool loading) {
    _isLoading.value = loading;
  }

  /// Met à jour l'état de création
  void _setCreatingState(bool creating) {
    _isCreating.value = creating;
  }

  /// Met à jour l'état de mise à jour
  void _setUpdatingState(bool updating) {
    _isUpdating.value = updating;
  }

  /// Met à jour l'état de suppression
  void _setDeletingState(bool deleting) {
    _isDeleting.value = deleting;
  }

  /// Gère les erreurs
  void _handleError(String message, dynamic error) {
    _hasError.value = true;
    _errorMessage.value = message;
    
    debugPrint('❌ $message: $error');
    _showErrorSnackbar(message);
  }

  /// Efface l'état d'erreur
  void _clearError() {
    _hasError.value = false;
    _errorMessage.value = '';
  }

  /// Définit l'état vide
  void _setEmptyState() {
    _errorMessage.value = "Aucun template fiche contrôle trouvé pour cette activité";
  }

  /// Affiche un snackbar d'erreur
  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Erreur',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade100,
      colorText: Colors.red.shade800,
      icon: const Icon(Icons.error_outline, color: Colors.red),
      duration: const Duration(seconds: 4),
    );
  }

  /// Affiche un snackbar de succès
  void _showSuccessSnackbar(String message) {
    Get.snackbar(
      'Succès',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade100,
      colorText: Colors.green.shade800,
      icon: const Icon(Icons.check_circle_outline, color: Colors.green),
      duration: const Duration(seconds: 3),
    );
  }

  /// Réessaie le chargement des données
  Future<void> retryLoading() async {
    await refreshTemplates();
  }

  @override
  void onClose() {
    // Nettoyage des ressources si nécessaire
    super.onClose();
  }
}