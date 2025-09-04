import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/core/template_model.dart';
import '../../services/core/fiche_controle_service.dart';

class FicheControleController extends GetxController {
  final FicheControleService _ficheService = Get.find<FicheControleService>();
  
  // États réactifs
  final RxBool isSubmitting = false.obs;
  final RxString errorMessage = ''.obs;
  
  /// Soumettre le formulaire complet au serveur
  Future<bool> submitFormulaire({
    required TemplateFichecontrole template,
    required int activiteSpecifiqueId,
    required Map<String, String> enteteValues,
    required Map<String, dynamic> schemaData,
    required File? photoObligatoire,
    required File signatureFile,
    List<Map<String, dynamic>>? anomalies,
  }) async {
    try {
      isSubmitting.value = true;
      errorMessage.value = '';
      
      // Validation des champs obligatoires
      if (photoObligatoire == null) {
        throw Exception('La photo est obligatoire pour valider le formulaire');
      }
      
      // Préparer les données de la fiche
      final ficheData = {
        'activite_specifique': activiteSpecifiqueId,
        'template': template.id,
        'nom': template.nom,
        'donnees': schemaData, // Données du tableau JSON
        'etat_de_la_fiche': 'Remplis', // État après signature qualiticient
      };
      
      // Préparer les entêtes au format attendu par le serializer
      final List<Map<String, dynamic>> enteteValuesList = enteteValues.entries.map((entry) {
        return {
          'entete': int.tryParse(entry.key) ?? 0, // ID de l'entête
          'valeur': entry.value,
        };
      }).toList();
      
      print('📋 Préparation soumission formulaire...');
      print('🎯 Template: ${template.nom}');
      print('📊 Entêtes: ${enteteValuesList.length} valeurs');
      print('📷 Photo: ${photoObligatoire.path}');
      print('✍️ Signature: ${signatureFile.path}');
      print('⚠️ Anomalies: ${anomalies?.length ?? 0}');
      
      // Appel au service pour créer la fiche
      final ficheCreee = await _ficheService.creerFicheControle(
        ficheData: ficheData,
        enteteValues: enteteValuesList,
        photoObligatoire: photoObligatoire,
        signatureQualiticient: signatureFile,
        anomalies: anomalies,
      );
      
      print('✅ Fiche contrôle créée avec succès - ID: ${ficheCreee['id']}');
      
      // Afficher un message de succès
      Get.snackbar(
        '✅ Formulaire envoyé',
        'La fiche de contrôle a été créée avec succès',
        backgroundColor: Get.theme.primaryColor.withOpacity(0.1),
        colorText: Get.theme.primaryColor,
        duration: const Duration(seconds: 3),
      );
      
      return true;
      
    } catch (e) {
      print('❌ Erreur lors de la soumission: $e');
      errorMessage.value = e.toString();
      
      Get.snackbar(
        '❌ Erreur',
        'Impossible d\'envoyer le formulaire: ${e.toString()}',
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.1),
        colorText: Get.theme.colorScheme.error,
        duration: const Duration(seconds: 5),
      );
      
      return false;
      
    } finally {
      isSubmitting.value = false;
    }
  }
  
  /// Validation avant soumission
  bool validateFormulaire({
    required Map<String, String> enteteValues,
    required File? photoObligatoire,
    required File? signatureFile,
  }) {
    final List<String> erreurs = [];
    
    // Vérifier les entêtes obligatoires
    if (enteteValues.isEmpty) {
      erreurs.add('Veuillez remplir au moins un champ d\'entête');
    }
    
    // Vérifier la photo obligatoire
    if (photoObligatoire == null) {
      erreurs.add('La photo est obligatoire');
    }
    
    // Vérifier la signature obligatoire
    if (signatureFile == null) {
      erreurs.add('La signature est obligatoire');
    }
    
    if (erreurs.isNotEmpty) {
      errorMessage.value = erreurs.join('\n');
      Get.snackbar(
        '⚠️ Formulaire incomplet',
        erreurs.join('\n'),
        backgroundColor: Colors.orange.withOpacity(0.1),
        colorText: Colors.orange.shade700,
        duration: const Duration(seconds: 4),
      );
      return false;
    }
    
    return true;
  }
  
  /// Reset du controller
  void resetController() {
    isSubmitting.value = false;
    errorMessage.value = '';
  }
  
  @override
  void onClose() {
    resetController();
    super.onClose();
  }
}
