import 'package:get/get.dart';
import 'package:mobile_vqc_new_version/config/config.dart';
import 'package:mobile_vqc_new_version/services/auth/auth_service.dart';

class FicheRemplisService  extends GetConnect{

  static FicheRemplisService get to => Get.find<FicheRemplisService>();

  @override
  void onInit() {
    httpClient.baseUrl = AppConfig.baseUrl;
    
    // Configuration globale des en-têtes avec authentification automatique
    httpClient.addRequestModifier<dynamic>((request) async {
      final authService = Get.find<AuthService>();
      final token = authService.token;

      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
        request.headers['Content-Type'] = 'application/json';
      }
      
      return request;
    });
  }


  /// Récupérer les fiches remplis par template 
  
  Future <List<dynamic>> getFichesRemplisByTemplate(int templateId) async {
    try {
      print('🔍 Récupération des fiches remplies pour le template: $templateId');
      
      final response = await get('/fiche-controle-remplie/by-template/$templateId/');

      print('📡 Statut de la réponse: ${response.statusCode}');
      print('📄 Corps de la réponse: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.body;
        print('✅ ${jsonList.length} fiche(s) récupérée(s)');
        
        return jsonList;
      } else if (response.statusCode == 404) {
        print('⚠️ Aucune fiche trouvée pour ce template');
        return [];
      } else {
        print('❌ Erreur HTTP: ${response.statusCode}');
        throw Exception('Erreur lors de la récupération des fiches: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Erreur lors de la récupération des fiches: $e');
      rethrow;
    }
  }
}