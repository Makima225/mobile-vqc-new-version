import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:mobile_vqc_new_version/config/config.dart';
import 'package:mobile_vqc_new_version/services/auth/auth_service.dart';

class FicheRemplisDetailsService  extends GetConnect{

  static FicheRemplisDetailsService get to => Get.find<FicheRemplisDetailsService>();

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


    /// 🔍 **Récupérer une fiche remplie par son ID**
  Future <Map<String, dynamic>> getFicheRemplieDetailById(int ficheId) async {
    try {
      print('🔍 Récupération du détail de la fiche remplie ID: $ficheId');
      
      final response = await get('/fiche-controle-remplie/detail/$ficheId/');

      print('📡 Statut de la réponse: ${response.statusCode}');
      print('📄 Corps de la réponse: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonMap = response.body;
        print('✅ Détail de la fiche récupéré avec succès');
        
        return jsonMap;
      } else if (response.statusCode == 404) {
        print('⚠️ Fiche non trouvée pour l\'ID: $ficheId');
        return {};
      } else {
        print('❌ Erreur HTTP: ${response.statusCode}');
        throw Exception('Erreur lors de la récupération du détail de la fiche: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Erreur lors de la récupération du détail de la fiche: $e');
      rethrow;
    }

  }
  /// Mettre à jour la fiche avec la signature de l'ingénieur travaux
  Future<void> updateFicheWithIngenieurSignature({
    required int ficheId,
    required Uint8List signatureImage,
  }) async {
    try {
      final url = Uri.parse("${httpClient.baseUrl}/fiche-controle-remplie/update-with-signature-ingenieur/$ficheId/");
      final token = AuthService.to.token;

      if (signatureImage.isEmpty) {
        throw Exception('La signature de l\'ingénieur travaux est obligatoire.');
      }

      final request = http.MultipartRequest('PATCH', url)
        ..headers['Authorization'] = 'Bearer $token'
        ..headers['Content-Type'] = 'multipart/form-data';

      request.files.add(http.MultipartFile.fromBytes(
        'signature_ingenieur_travaux',
        signatureImage,
        filename: 'signature_ingenieur.png',
      ));

      print("🔍 Envoi de la signature de l'ingénieur travaux pour la fiche ID: $ficheId");
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print('📨 Réponse du serveur : $responseBody');

      if (response.statusCode == 200) {
        print('✅ Signature de l\'ingénieur travaux mise à jour avec succès');
      } else {
        print('❌ Erreur détaillée : $responseBody');
        throw Exception(
          'Erreur lors de la mise à jour de la signature: ${response.statusCode}\n'
          'Réponse: $responseBody'
        );
      }
    } catch (e, stackTrace) {
      print('❌ Erreur de requête : $e');
      print('🔍 Détails : $stackTrace');
      rethrow;
    }
  }
}