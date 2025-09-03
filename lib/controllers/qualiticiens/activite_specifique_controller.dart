import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../services/core/activite_specifique_by_activite_generale_service.dart';
import '../../models/core/activite_specifique_model.dart';

/// Controller optimisé pour la gestion des activités spécifiques des qualiticiens
/// Gère les états de chargement, erreurs, données et filtrage par activité générale
class ActiviteSpecifiqueController extends GetxController {
  // Services
  final ActiviteSpecifiqueByActiviteGeneraleService _activiteSpecifiqueService = Get.find<ActiviteSpecifiqueByActiviteGeneraleService>();

  // État des données
  final _activitesSpecifiques = <ActiviteSpecifique>[].obs;
  final _isLoading = false.obs;
  final _errorMessage = ''.obs;
  final _hasError = false.obs;

  // État de sélection de l'activité générale
  final _selectedActiviteGeneraleId = Rx<int?>(null);
  final _selectedActiviteGeneraleTitre = ''.obs;

  // Getters pour l'accès aux données
  List<ActiviteSpecifique> get activitesSpecifiques => _activitesSpecifiques;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;
  bool get hasError => _hasError.value;
  bool get hasData => _activitesSpecifiques.isNotEmpty;
  int? get selectedActiviteGeneraleId => _selectedActiviteGeneraleId.value;
  String get selectedActiviteGeneraleTitre => _selectedActiviteGeneraleTitre.value;

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
      _selectedActiviteGeneraleId.value = arguments['activiteGeneraleId'];
      _selectedActiviteGeneraleTitre.value = arguments['activiteGeneraleTitre'] ?? '';
    }
  }

  /// Charge les données initiales
  Future<void> _loadInitialData() async {
    await fetchActivitesSpecifiques();
  }

  /// Récupère les activités spécifiques depuis l'API
  Future<void> fetchActivitesSpecifiques() async {
    try {
      _setLoadingState(true);
      _clearError();

      List<dynamic> responseData;

      if (_selectedActiviteGeneraleId.value != null) {
        // Récupérer les activités spécifiques pour une activité générale spécifique
        responseData = await _activiteSpecifiqueService.getActivitesSpecifiquesByActiviteGenerale(
          _selectedActiviteGeneraleId.value!
        );
      } else {
        // Récupérer toutes les activités spécifiques
        responseData = await _activiteSpecifiqueService.getAllActivitesSpecifiques();
      }

      // Convertir les données en objets ActiviteSpecifique
      final List<ActiviteSpecifique> activites = responseData
          .map((json) => ActiviteSpecifique.fromJson(json as Map<String, dynamic>))
          .toList();

      _activitesSpecifiques.assignAll(activites);

      // Vérifier si des données ont été récupérées
      if (_activitesSpecifiques.isEmpty) {
        _setEmptyState();
      }

    } catch (e) {
      _handleError('Erreur lors de la récupération des activités spécifiques', e);
    } finally {
      _setLoadingState(false);
    }
  }

  /// Rafraîchit les données
  Future<void> refreshActivitesSpecifiques() async {
    _clearError();
    await fetchActivitesSpecifiques();
  }

  /// Filtre les activités par activité générale
  void filterByActiviteGenerale(int activiteGeneraleId, String activiteGeneraleTitre) {
    _selectedActiviteGeneraleId.value = activiteGeneraleId;
    _selectedActiviteGeneraleTitre.value = activiteGeneraleTitre;
    fetchActivitesSpecifiques();
  }

  /// Supprime le filtre d'activité générale
  void clearActiviteGeneraleFilter() {
    _selectedActiviteGeneraleId.value = null;
    _selectedActiviteGeneraleTitre.value = '';
    fetchActivitesSpecifiques();
  }

  /// Récupère une activité spécifique par ID
  Future<ActiviteSpecifique?> getActiviteSpecifiqueById(int id) async {
    try {
      _setLoadingState(true);
      _clearError();

      final responseData = await _activiteSpecifiqueService.getActiviteSpecifiqueById(id);
      
      if (responseData != null) {
        return ActiviteSpecifique.fromJson(responseData);
      }
      
      return null;
    } catch (e) {
      _handleError('Erreur lors de la récupération de l\'activité spécifique', e);
      return null;
    } finally {
      _setLoadingState(false);
    }
  }

  /// Crée une nouvelle activité spécifique
  Future<bool> createActiviteSpecifique({
    required String titre,
    required int activiteGeneraleId,
  }) async {
    try {
      _setLoadingState(true);
      _clearError();

      final data = {
        'titre': titre,
        'activite_generale': activiteGeneraleId,
      };

      final result = await _activiteSpecifiqueService.createActiviteSpecifique(data);
      
      if (result != null) {
        _showSuccessSnackbar('Activité spécifique créée avec succès');
        // Rafraîchir la liste
        await fetchActivitesSpecifiques();
        return true;
      }
      
      _handleError('Erreur lors de la création de l\'activité spécifique', null);
      return false;
    } catch (e) {
      _handleError('Erreur lors de la création de l\'activité spécifique', e);
      return false;
    } finally {
      _setLoadingState(false);
    }
  }

  /// Met à jour une activité spécifique
  Future<bool> updateActiviteSpecifique({
    required int id,
    required String titre,
    required int activiteGeneraleId,
  }) async {
    try {
      _setLoadingState(true);
      _clearError();

      final data = {
        'titre': titre,
        'activite_generale': activiteGeneraleId,
      };

      final result = await _activiteSpecifiqueService.updateActiviteSpecifique(id, data);
      
      if (result != null) {
        _showSuccessSnackbar('Activité spécifique mise à jour avec succès');
        // Rafraîchir la liste
        await fetchActivitesSpecifiques();
        return true;
      }
      
      _handleError('Erreur lors de la mise à jour de l\'activité spécifique', null);
      return false;
    } catch (e) {
      _handleError('Erreur lors de la mise à jour de l\'activité spécifique', e);
      return false;
    } finally {
      _setLoadingState(false);
    }
  }

  /// Supprime une activité spécifique
  Future<bool> deleteActiviteSpecifique(int id) async {
    try {
      _setLoadingState(true);
      _clearError();

      final result = await _activiteSpecifiqueService.deleteActiviteSpecifique(id);
      
      if (result) {
        _showSuccessSnackbar('Activité spécifique supprimée avec succès');
        // Rafraîchir la liste
        await fetchActivitesSpecifiques();
        return true;
      }
      
      _handleError('Erreur lors de la suppression de l\'activité spécifique', null);
      return false;
    } catch (e) {
      _handleError('Erreur lors de la suppression de l\'activité spécifique', e);
      return false;
    } finally {
      _setLoadingState(false);
    }
  }

  /// Recherche dans les activités spécifiques
  List<ActiviteSpecifique> searchActivites(String query) {
    if (query.isEmpty) return _activitesSpecifiques;
    
    return _activitesSpecifiques.where((activite) {
      return activite.titre.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  /// Met à jour l'état de chargement
  void _setLoadingState(bool loading) {
    _isLoading.value = loading;
  }

  /// Gère les erreurs
  void _handleError(String message, dynamic error) {
    _hasError.value = true;
    _errorMessage.value = message;
    
    // Log pour le débogage
    debugPrint('❌ $message: $error');
    
    // Afficher un snackbar à l'utilisateur
    _showErrorSnackbar(message);
  }

  /// Efface l'état d'erreur
  void _clearError() {
    _hasError.value = false;
    _errorMessage.value = '';
  }

  /// Définit l'état vide
  void _setEmptyState() {
    _errorMessage.value = _selectedActiviteGeneraleId.value != null
        ? "Aucune activité spécifique trouvée pour cette activité générale"
        : "Aucune activité spécifique trouvée";
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
    await fetchActivitesSpecifiques();
  }

  /// Affiche une boîte de dialogue de confirmation pour la suppression
  Future<bool> showDeleteConfirmation(String activiteTitre) async {
    return await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer l\'activité spécifique "$activiteTitre" ?\n\nCette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  void onClose() {
    // Nettoyage des ressources si nécessaire
    super.onClose();
  }
}