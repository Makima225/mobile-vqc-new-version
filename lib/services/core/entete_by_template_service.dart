import 'package:get/get.dart';
import '../../models/core/entete_model.dart';
import '../../config/config.dart';
import '../auth/auth_service.dart';

class EnteteByTemplateService extends GetConnect {
  static EnteteByTemplateService get to => Get.find<EnteteByTemplateService>();

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

  /// Récupérer les entêtes d'un template spécifique
  Future<List<Entete>> getEntetesByTemplate(int templateId) async {
    try {
      print('🔍 Récupération des entêtes pour le template: $templateId');
      
      final response = await get('/entetes/by-template/$templateId/');

      print('📡 Statut de la réponse: ${response.statusCode}');
      print('📄 Corps de la réponse: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.body;
        print('✅ ${jsonList.length} entête(s) récupéré(s)');
        
        return jsonList.map((json) => Entete.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        print('⚠️ Aucun entête trouvé pour ce template');
        return [];
      } else {
        print('❌ Erreur HTTP: ${response.statusCode}');
        throw Exception('Erreur lors de la récupération des entêtes: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Erreur lors de la récupération des entêtes: $e');
      rethrow;
    }
  }
}
