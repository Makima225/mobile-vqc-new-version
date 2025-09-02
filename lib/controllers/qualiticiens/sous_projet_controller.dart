import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../models/core/sous_projet_model.dart';
import '../../services/core/sous_projets_service.dart';

class QualiticiansousProjetController extends GetxController {
  final SousProjetService _sousProjetService = Get.find<SousProjetService>();

  var sousProjets = <SousProjet>[].obs;
  var selectedSousProjet = Rx<SousProjet?>(null);
  var sousProjetDetails = Rx<SousProjet?>(null);
  
  var isLoading = false.obs;
  var isLoadingDetails = false.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeData();
  }

  // Initialiser les données
  void _initializeData() async {
    await fetchSousProjets();
  }

  // Récupérer la liste des sous-projets liés au qualiticien connecté
  Future<void> fetchSousProjets() async {
    try {
      isLoading(true);
      errorMessage.value = '';
      
      print('🔄 Récupération des sous-projets...');
      final List<SousProjet> sousProjetsList = await _sousProjetService.getSousProjetsForQualiticien();
      
      sousProjets.assignAll(sousProjetsList);
      
      print('✅ ${sousProjetsList.length} sous-projets récupérés');
      
      if (sousProjets.isEmpty) {
        errorMessage.value = "Aucun sous-projet trouvé pour ce qualiticien";
        Get.snackbar(
          'Information',
          'Aucun sous-projet assigné',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('❌ Erreur lors de la récupération des sous-projets : $e');
      errorMessage.value = "Erreur lors de la récupération des sous-projets";
      Get.snackbar(
        'Erreur',
        'Impossible de récupérer les sous-projets',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading(false);
    }
  }

  // Sélectionner un sous-projet et charger ses détails
  void selectSousProjet(SousProjet sousProjet) {
    selectedSousProjet.value = sousProjet;
    fetchSousProjetDetails(sousProjet.id);
  }

  // Récupérer les détails d'un sous-projet spécifique
  Future<void> fetchSousProjetDetails(int sousProjetId) async {
    try {
      isLoadingDetails(true);
      errorMessage.value = '';
      
      print('🔄 Récupération des détails du sous-projet $sousProjetId...');
      final SousProjet? details = await _sousProjetService.getSousProjetDetails(sousProjetId);
      
      if (details != null) {
        sousProjetDetails.value = details;
        print('✅ Détails du sous-projet récupérés');
      } else {
        errorMessage.value = "Aucun détail trouvé pour ce sous-projet";
        Get.snackbar(
          'Erreur',
          'Impossible de récupérer les détails du sous-projet',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('❌ Erreur lors de la récupération des détails du sous-projet : $e');
      errorMessage.value = "Erreur lors de la récupération des détails";
      Get.snackbar(
        'Erreur',
        'Erreur lors de la récupération des détails',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingDetails(false);
    }
  }

  // Rafraîchir la liste des sous-projets
  Future<void> refreshSousProjets() async {
    errorMessage.value = '';
    await fetchSousProjets();
    
    // Si un sous-projet était sélectionné, rafraîchir aussi ses détails
    if (selectedSousProjet.value != null) {
      await fetchSousProjetDetails(selectedSousProjet.value!.id);
    }
    
    Get.snackbar(
      'Succès',
      'Données rafraîchies',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  // Créer un nouveau sous-projet
  Future<void> createSousProjet(SousProjet sousProjet) async {
    try {
      isLoading(true);
      errorMessage.value = '';
      
      print('🔄 Création du sous-projet...');
      final SousProjet? newSousProjet = await _sousProjetService.createSousProjet(sousProjet);
      
      if (newSousProjet != null) {
        sousProjets.add(newSousProjet);
        print('✅ Sous-projet créé avec succès');
        
        Get.snackbar(
          'Succès',
          'Sous-projet créé avec succès',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('❌ Erreur lors de la création du sous-projet : $e');
      errorMessage.value = "Erreur lors de la création du sous-projet";
    } finally {
      isLoading(false);
    }
  }

  // Mettre à jour un sous-projet
  Future<void> updateSousProjet(int id, SousProjet sousProjet) async {
    try {
      isLoading(true);
      errorMessage.value = '';
      
      print('🔄 Mise à jour du sous-projet...');
      final SousProjet? updatedSousProjet = await _sousProjetService.updateSousProjet(id, sousProjet);
      
      if (updatedSousProjet != null) {
        // Mettre à jour dans la liste
        final index = sousProjets.indexWhere((sp) => sp.id == id);
        if (index != -1) {
          sousProjets[index] = updatedSousProjet;
        }
        
        // Mettre à jour la sélection si c'est le même sous-projet
        if (selectedSousProjet.value?.id == id) {
          selectedSousProjet.value = updatedSousProjet;
          sousProjetDetails.value = updatedSousProjet;
        }
        
        print('✅ Sous-projet mis à jour avec succès');
      }
    } catch (e) {
      print('❌ Erreur lors de la mise à jour du sous-projet : $e');
      errorMessage.value = "Erreur lors de la mise à jour du sous-projet";
    } finally {
      isLoading(false);
    }
  }

  // Supprimer un sous-projet
  Future<void> deleteSousProjet(int id) async {
    try {
      isLoading(true);
      errorMessage.value = '';
      
      print('🔄 Suppression du sous-projet...');
      final bool success = await _sousProjetService.deleteSousProjet(id);
      
      if (success) {
        // Supprimer de la liste
        sousProjets.removeWhere((sp) => sp.id == id);
        
        // Effacer la sélection si c'est le même sous-projet
        if (selectedSousProjet.value?.id == id) {
          clearSelection();
        }
        
        print('✅ Sous-projet supprimé avec succès');
      }
    } catch (e) {
      print('❌ Erreur lors de la suppression du sous-projet : $e');
      errorMessage.value = "Erreur lors de la suppression du sous-projet";
    } finally {
      isLoading(false);
    }
  }

  // Rechercher des sous-projets par titre
  List<SousProjet> searchSousProjets(String query) {
    if (query.isEmpty) return sousProjets;
    
    return sousProjets.where((sousProjet) => 
      sousProjet.titre.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  // Filtrer les sous-projets par projet
  List<SousProjet> filterByProjet(int projetId) {
    return sousProjets.where((sousProjet) => 
      sousProjet.projetId == projetId
    ).toList();
  }

  // Vérifier si un sous-projet est sélectionné
  bool hasSousProjetSelected() {
    return selectedSousProjet.value != null;
  }
  
  // Effacer la sélection actuelle
  void clearSelection() {
    selectedSousProjet.value = null;
    sousProjetDetails.value = null;
  }

  // Obtenir le nombre total de sous-projets
  int get totalSousProjets => sousProjets.length;

  // Vérifier si la liste est vide
  bool get isEmpty => sousProjets.isEmpty;

  // Vérifier si des données sont en cours de chargement
  bool get isAnyLoading => isLoading.value || isLoadingDetails.value;

  // Obtenir le sous-projet sélectionné de manière sécurisée
  SousProjet? get currentSousProjet => selectedSousProjet.value;

  // Obtenir les détails du sous-projet sélectionné
  SousProjet? get currentDetails => sousProjetDetails.value;
}
