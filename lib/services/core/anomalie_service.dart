import 'dart:io';
import 'package:get/get.dart';
import '../../models/core/anomalie_model.dart';
import '../../config/config.dart';
import '../auth/auth_service.dart';

class AnomalieService extends GetConnect {
  static AnomalieService get to => Get.find<AnomalieService>();
  
  final AuthService _authService = Get.find<AuthService>();

  @override
  void onInit() {
    super.onInit();
    
    // Configuration de base
    httpClient.baseUrl = AppConfig.baseUrl;
    httpClient.timeout = const Duration(seconds: 30);
    
    // Intercepteur pour ajouter le token d'authentification
    httpClient.addRequestModifier<void>((request) {
      final token = _authService.token;
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      return request;
    });
  }

  /// Signaler une nouvelle anomalie
  Future<Anomalie> signalerAnomalie({
    required int ficheControleId,
    required String description,
    File? photo,
  }) async {
    try {
      final form = FormData({
        'fiche_controle': ficheControleId.toString(),
        'description': description,
      });

      // Ajouter la photo si elle existe
      if (photo != null) {
        form.files.add(MapEntry(
          'photo',
          MultipartFile(photo, filename: photo.path.split('/').last),
        ));
      }

      print('📤 Envoi de l\'anomalie...');
      final response = await post('/anomalies/', form);

      if (response.hasError) {
        print('❌ Erreur HTTP: ${response.statusCode}');
        print('📋 Data: ${response.body}');
        throw Exception('Erreur lors du signalement: ${response.statusText}');
      }

      print('✅ Anomalie créée avec succès: ${response.body}');
      return Anomalie.fromJson(response.body);
      
    } catch (e) {
      print('❌ Erreur lors du signalement de l\'anomalie: $e');
      throw Exception('Erreur inattendue lors du signalement de l\'anomalie');
    }
  }

  /// Récupérer les anomalies d'une fiche de contrôle
  Future<List<Anomalie>> getAnomaliesByFicheControle(int ficheControleId) async {
    try {
      print('📥 Récupération des anomalies pour la fiche $ficheControleId...');
      
      final response = await get('/anomalies/', query: {
        'fiche_controle': ficheControleId.toString(),
      });

      if (response.hasError) {
        print('❌ Erreur HTTP: ${response.statusCode}');
        print('📋 Data: ${response.body}');
        throw Exception('Erreur lors de la récupération: ${response.statusText}');
      }

      print('✅ ${response.body['results'].length} anomalie(s) récupérée(s)');
      
      List<Anomalie> anomalies = [];
      if (response.body['results'] != null) {
        for (var anomalieData in response.body['results']) {
          anomalies.add(Anomalie.fromJson(anomalieData));
        }
      }
      
      return anomalies;
      
    } catch (e) {
      print('❌ Erreur lors de la récupération des anomalies: $e');
      throw Exception('Erreur inattendue lors de la récupération des anomalies');
    }
  }

  /// Supprimer une anomalie
  Future<void> supprimerAnomalie(int anomalieId) async {
    try {
      print('🗑️ Suppression de l\'anomalie $anomalieId...');
      
      final response = await delete('/anomalies/$anomalieId/');
      
      if (response.hasError) {
        print('❌ Erreur HTTP: ${response.statusCode}');
        print('📋 Data: ${response.body}');
        throw Exception('Erreur lors de la suppression: ${response.statusText}');
      }
      
      print('✅ Anomalie supprimée avec succès');
      
    } catch (e) {
      print('❌ Erreur lors de la suppression de l\'anomalie: $e');
      throw Exception('Erreur inattendue lors de la suppression de l\'anomalie');
    }
  }
}
