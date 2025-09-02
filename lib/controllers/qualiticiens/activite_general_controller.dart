import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../services/core/activite_generale_service.dart';
import '../../models/core/activite_generale_model.dart';

/// Controller optimisé pour la gestion des activités générales des qualiticiens
/// Gère les états de chargement, erreurs, données en cache et connectivité
class ActiviteGeneralController extends GetxController {
  // Services
  final ActiviteGeneraleService _activiteGeneraleService = Get.find<ActiviteGeneraleService>();

  // État des données
  final _activitesGenerales = <ActiviteGenerale>[].obs;
  final _isLoading = false.obs;
  final _errorMessage = ''.obs;
  final _hasError = false.obs;

  // État de sélection du sous-projet
  final _selectedSousProjetId = Rx<int?>(null);
  final _selectedSousProjetTitre = ''.obs;

  // Getters pour l'accès aux données
  List<ActiviteGenerale> get activitesGenerales => _activitesGenerales;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;
  bool get hasError => _hasError.value;
  bool get hasData => _activitesGenerales.isNotEmpty;
  int? get selectedSousProjetId => _selectedSousProjetId.value;
  String get selectedSousProjetTitre => _selectedSousProjetTitre.value;

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
      _selectedSousProjetId.value = arguments['sousProjetId'];
      _selectedSousProjetTitre.value = arguments['sousProjetTitre'] ?? '';
    }
  }

  /// Charge les données initiales
  Future<void> _loadInitialData() async {
    await fetchActivitesGenerales();
  }

  /// Récupère les activités générales depuis l'API
  Future<void> fetchActivitesGenerales() async {
    try {
      _setLoadingState(true);
      _clearError();

      List<dynamic> responseData;

      if (_selectedSousProjetId.value != null) {
        // Récupérer les activités pour un sous-projet spécifique
        responseData = await _activiteGeneraleService.getActivitesGeneralesBySousProjet(
          _selectedSousProjetId.value!
        );
      } else {
        // Récupérer toutes les activités du qualiticien
        responseData = await _activiteGeneraleService.getActivitesGeneralesByQualiticient();
      }

      // Convertir les données en objets ActiviteGenerale
      final List<ActiviteGenerale> activites = responseData
          .map((json) => ActiviteGenerale.fromJson(json as Map<String, dynamic>))
          .toList();

      _activitesGenerales.assignAll(activites);

      // Vérifier si des données ont été récupérées
      if (_activitesGenerales.isEmpty) {
        _setEmptyState();
      }

    } catch (e) {
      _handleError('Erreur lors de la récupération des activités générales', e);
    } finally {
      _setLoadingState(false);
    }
  }

  /// Rafraîchit les données
  Future<void> refreshActivitesGenerales() async {
    _clearError();
    await fetchActivitesGenerales();
  }

  /// Filtre les activités par sous-projet
  void filterBySousProjet(int sousProjetId, String sousProjetTitre) {
    _selectedSousProjetId.value = sousProjetId;
    _selectedSousProjetTitre.value = sousProjetTitre;
    fetchActivitesGenerales();
  }

  /// Supprime le filtre de sous-projet
  void clearSousProjetFilter() {
    _selectedSousProjetId.value = null;
    _selectedSousProjetTitre.value = '';
    fetchActivitesGenerales();
  }

  /// Recherche dans les activités générales
  List<ActiviteGenerale> searchActivites(String query) {
    if (query.isEmpty) return _activitesGenerales;
    
    return _activitesGenerales.where((activite) {
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
    _errorMessage.value = _selectedSousProjetId.value != null
        ? "Aucune activité générale trouvée pour ce sous-projet"
        : "Aucune activité générale trouvée";
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

  /// Réessaie le chargement des données
  Future<void> retryLoading() async {
    await fetchActivitesGenerales();
  }

  @override
  void onClose() {
    // Nettoyage des ressources si nécessaire
    super.onClose();
  }
}