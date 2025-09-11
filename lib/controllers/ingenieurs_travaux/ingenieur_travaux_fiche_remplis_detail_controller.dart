import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:mobile_vqc_new_version/models/core/anomalie_model.dart';
import 'package:mobile_vqc_new_version/models/core/entete_value_model.dart';
import 'package:mobile_vqc_new_version/models/core/qualiticient_details_model.dart';
import 'package:mobile_vqc_new_version/services/core/fiche_remplis_details_service.dart';



class IngenieurTravauxFicheRemplisDetailController extends GetxController{

  final FicheRemplisDetailsService _ficheRemplisDetailsService = Get.put(FicheRemplisDetailsService());

  var ficheRemplie = {}.obs;
  var anomalies = <Anomalie>[].obs;
  var entete_values = <EnteteValue>[].obs;
  var qualiticient_details = <QualiticientDetails>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;


   // Variable pour stocker la signature
  Rx<Uint8List?> signatureImage = Rx<Uint8List?>(null);

  /// Récupérer le détail d'une fiche remplie par son ID
  Future<void> fetchFicheRemplieDetailById(int ficheId) async {
    try {
      isLoading(true);
      errorMessage.value = '';
      final data = await _ficheRemplisDetailsService.getFicheRemplieDetailById(ficheId);
      ficheRemplie.value = data;

      // Parse et assigner les listes imbriquées
      if (data.containsKey('anomalies')) {
        final List<dynamic> anomaliesJson = data['anomalies'];
        print('🔍 Debug Controller: ${anomaliesJson.length} anomalies reçues du backend');
        print('🔍 Debug Controller: JSON des anomalies: $anomaliesJson');
        anomalies.assignAll(anomaliesJson.map((json) => Anomalie.fromJson(json)).toList());
        print('🔍 Debug Controller: ${anomalies.length} anomalies parsées et assignées');
      } else {
        print('⚠️ Debug Controller: Aucune clé "anomalies" trouvée dans la réponse');
        print('🔍 Debug Controller: Clés disponibles: ${data.keys.toList()}');
        anomalies.clear();
      }

      if (data.containsKey('entete_values')) {
        final List<dynamic> enteteValuesJson = data['entete_values'];
        entete_values.assignAll(enteteValuesJson.map((json) => EnteteValue.fromJson(json)).toList());
      } else {
        entete_values.clear();
      }

      if (data.containsKey('qualiticient_details')) {
        final qualiticientDetailsJson = data['qualiticient_details'];
        qualiticient_details.assignAll([QualiticientDetails.fromJson(qualiticientDetailsJson)]);
      } else {
        qualiticient_details.clear();
      }

    } catch (e) {
      errorMessage.value = '❌ Erreur lors de la récupération du détail de la fiche : $e';
      ficheRemplie.clear();
      anomalies.clear();
      entete_values.clear();
      qualiticient_details.clear();
    } finally {
      isLoading(false);
    }
  }

  // Méthode pour mettre à jour la signature
  void setSignature(Uint8List? signature) {
    signatureImage.value = signature;
  }  


  /// Mettre à jour la fiche avec la signature de l'ingénieur travaux
  Future<void> updateFicheWithIngenieurSignature({
    required int ficheId,
    required Uint8List signatureImage,
  }) async {
    try {
      isLoading(true);
      errorMessage.value = '';
      await _ficheRemplisDetailsService.updateFicheWithIngenieurSignature(
        ficheId: ficheId,
        signatureImage: signatureImage,
      );
    } catch (e) {
      errorMessage.value = '❌ Erreur lors de la mise à jour de la fiche : $e';
    } finally {
      isLoading(false);
    }
  }
}