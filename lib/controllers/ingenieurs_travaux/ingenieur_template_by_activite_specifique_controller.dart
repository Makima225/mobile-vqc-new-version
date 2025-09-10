import 'package:get/get.dart';
import 'package:mobile_vqc_new_version/services/core/template_by_activite_specifique_service.dart';



class IngenieurTemplateByActiviteSpecifiqueController  extends GetxController {

  final TemplateFichecontroleByActiviteSpecifiqueService _templateService = Get.find<TemplateFichecontroleByActiviteSpecifiqueService>();

  var activitesSpecifiques = <dynamic>[].obs;
  var isLoading = false.obs;
  var errorMessage =  ''.obs;

  // Récuperer les templates par activité spécifique
  Future<void> fetchTemplatesByActiviteSpecifique(int activiteSpecifiqueId) async {

      try {
          isLoading(true);
          errorMessage.value = '';

          final data = await _templateService.getTemplatesByActiviteSpecifique(activiteSpecifiqueId);
          activitesSpecifiques.assignAll(data);
      } catch(e) {
         errorMessage.value = "❌ Erreur lors de la récupération des templates : $e";
      } finally {
        isLoading(false);
      }
   }
}