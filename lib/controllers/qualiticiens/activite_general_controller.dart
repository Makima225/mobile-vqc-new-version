import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../services/core/activite_generale_service.dart';
import '../../models/core/activite_generale_model.dart';

/// Controller optimisé pour la gestion des activités générales des qualiticiens
/// Charge automatiquement les activités générales assignées au qualiticien connecté
/// Gère les états de chargement, erreurs et données
class ActiviteGeneralController extends GetxController {
  // Services
  final ActiviteGeneraleService _activiteGeneraleService = Get.find<ActiviteGeneraleService>();

  // État des données
  final _activitesGenerales = <ActiviteGenerale>[].obs;
  final _isLoading = false.obs;
  final _errorMessage = ''.obs;
  final _hasError = false.obs;

  // Getters pour l'accès aux données
  List<ActiviteGenerale> get activitesGenerales => _activitesGenerales;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;
  bool get hasError => _hasError.value;
  bool get hasData => _activitesGenerales.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    _loadInitialData();
  }

  /// Charge les données initiales
  /// Charge les activités générales assignées au qualiticien connecté
  Future<void> _loadInitialData() async {
    await fetchActivitesGenerales();
  }

  /// Récupère les activités générales depuis l'API
  /// Récupère TOUJOURS les activités générales liées au qualiticien connecté
  Future<void> fetchActivitesGenerales() async {
    try {
      _setLoadingState(true);
      _clearError();

      // Récupérer toutes les activités générales liées au qualiticien connecté
      debugPrint('🔍 Récupération activités générales pour qualiticien connecté');
      final responseData = await _activiteGeneraleService.getActivitesGeneralesByQualiticient();
      debugPrint('📊 Données reçues du backend : ${responseData.length} éléments');
      if (responseData.isNotEmpty) {
        debugPrint('📋 Premier élément reçu : ${responseData.first}');
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

      // Log pour le débogage
      debugPrint('✅ ${_activitesGenerales.length} activités générales chargées pour le qualiticien');

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
    _errorMessage.value = "Aucune activité générale assignée à votre compte qualiticien";
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