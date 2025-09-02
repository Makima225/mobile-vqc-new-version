import 'package:get/get.dart';
import '../../services/core/activite_generale_service.dart';

class ActiviteGeneraleController extends GetxController {
  final ActiviteGeneraleService _activiteGeneraleService = Get.find<ActiviteGeneraleService>();

  var activitesGenerales = <dynamic>[].obs;
  var isLoading = false.obs;
  var isRefreshing = false.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchActivitesGenerales();
  }

  // 🔹 Récupérer la liste des activités générales
  Future<void> fetchActivitesGenerales() async {
    try {
      isLoading(true);
      errorMessage.value = '';
      
      final data = await _activiteGeneraleService.getActivitesGenerales();
      activitesGenerales.assignAll(data);
    } catch (e) {
      errorMessage.value = "❌ Erreur lors de la récupération des activités générales : $e";
    } finally {
      isLoading(false);
    }
  }

  // 🔄 Rafraîchir les données
  Future<void> refreshData() async {
    isRefreshing.value = true;
    try {
      await fetchActivitesGenerales();
    } finally {
      isRefreshing.value = false;
    }
  }

  // 📊 Getters utilitaires
  bool get hasData => activitesGenerales.isNotEmpty;
  bool get hasError => errorMessage.value.isNotEmpty;
}