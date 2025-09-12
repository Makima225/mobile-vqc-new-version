import 'package:get/get.dart';
import 'package:mobile_vqc_new_version/services/core/fiche_remplis_service.dart';



class IngenieurFicheRemplisListController extends GetxController {
  final FicheRemplisService _ficheRemplisService = Get.put(FicheRemplisService());

  var fichesRemplies = <dynamic>[].obs;
  var isLoading = false.obs;
  var isRefreshing = false.obs; // Pour le loader overlay
  var errorMessage = ''.obs;

  /// Récupérer toutes les fiches remplies liées à un template
  Future<void> fetchFichesRempliesListByTemplate(int templateId, {bool showOverlay = false}) async {
    try {
      if (showOverlay) {
        isRefreshing(true);
      } else {
        isLoading(true);
      }
      errorMessage.value = '';
      final data = await _ficheRemplisService.getFichesRemplisByTemplate(templateId);
      fichesRemplies.assignAll(data);
    } catch (e) {
      errorMessage.value = '❌ Erreur lors de la récupération des fiches : $e';
      fichesRemplies.clear();
    } finally {
      if (showOverlay) {
        isRefreshing(false);
      } else {
        isLoading(false);
      }
    }
  }
}