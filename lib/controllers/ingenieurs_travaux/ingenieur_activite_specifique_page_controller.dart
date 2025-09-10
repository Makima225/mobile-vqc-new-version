import 'package:get/get.dart';
import 'package:mobile_vqc_new_version/services/core/activite_specifique_by_activite_generale_service.dart';


class IngenieurActiviteSpecifiquesPageController extends GetxController{

  final ActiviteSpecifiqueByActiviteGeneraleService _activiteSpecifiqueByActiviteGeneraleService = Get.put(ActiviteSpecifiqueByActiviteGeneraleService());

  var activitesSpecifiques = <dynamic>[].obs;
  var isLoading = false.obs;
  var errorMessage =  ''.obs;

   // 🔹 Récupérer les activités spécifiques par activité générale
   Future<void> fetchActivitesSpecifiques(int activiteGeneraleId) async {

      try {
          isLoading(true);
          errorMessage.value = '';

          final data = await _activiteSpecifiqueByActiviteGeneraleService.getActivitesSpecifiquesByActiviteGenerale(activiteGeneraleId);
          activitesSpecifiques.assignAll(data);
      } catch(e) {
         errorMessage.value = "❌ Erreur lors de la récupération des activités spécifiques : $e";
      } finally {
        isLoading(false);
      }
   }

}