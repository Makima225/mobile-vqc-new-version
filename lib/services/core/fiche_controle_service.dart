import 'dart:io';
import 'package:get/get.dart';
import '../../config/config.dart';
import '../auth/auth_service.dart';
// Extension pour encoder JSON
import 'dart:convert';

class FicheControleService extends GetConnect {
  static FicheControleService get to => Get.find<FicheControleService>();
  
  final AuthService _authService = Get.find<AuthService>();

  @override
  void onInit() {
    super.onInit();
    
    // Configuration de base
    httpClient.baseUrl = AppConfig.baseUrl;
    httpClient.timeout = const Duration(seconds: 60); // Plus long pour les uploads
    
    // Intercepteur pour ajouter le token d'authentification
    httpClient.addRequestModifier<void>((request) {
      final token = _authService.token;
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
        print('🔐 Token ajouté: ${token.substring(0, 20)}...');
      } else {
        print('⚠️ Aucun token disponible');
      }
      return request;
    });

    // Intercepteur pour gérer les erreurs 401 (token expiré)
    httpClient.addResponseModifier<void>((request, response) {
      if (response.statusCode == 401) {
        print('🔴 Token expiré détecté - tentative de refresh...');
        // Essayer de rafraîchir le token
        _authService.refreshToken();
      }
      return response;
    });
  }

  /// Créer une fiche de contrôle complète avec toutes les données
  Future<Map<String, dynamic>> creerFicheControle({
    required Map<String, dynamic> ficheData,
    required List<Map<String, dynamic>> enteteValues,
    required File photoObligatoire,
    required File signatureQualiticient,
    List<Map<String, dynamic>>? anomalies,
  }) async {
    try {
      print('�🔥🔥 === DÉBUT LOGS DÉTAILLÉS ENVOI FICHE CONTRÔLE === 🔥🔥🔥');
      print('�📤 Création fiche contrôle en cours...');
      
      // Log des données reçues
      print('📊 DONNÉES REÇUES:');
      print('  🎯 ficheData: $ficheData');
      print('  📝 enteteValues: $enteteValues');
      print('  📷 photoObligatoire path: ${photoObligatoire.path}');
      print('  📷 photoObligatoire exists: ${photoObligatoire.existsSync()}');
      print('  📷 photoObligatoire size: ${photoObligatoire.lengthSync()} bytes');
      print('  ✍️ signatureQualiticient path: ${signatureQualiticient.path}');
      print('  ✍️ signatureQualiticient exists: ${signatureQualiticient.existsSync()}');
      print('  ✍️ signatureQualiticient size: ${signatureQualiticient.lengthSync()} bytes');
      print('  ⚠️ anomalies: $anomalies');
      
      // Préparer le FormData avec toutes les données
      final form = FormData({
        // CORRECTION: Envoyer les IDs comme int, pas string
        'activite_specifique': ficheData['activite_specifique'], // int direct
        'template': ficheData['template'], // int direct
        'nom': ficheData['nom'],
        'donnees': ficheData['donnees'] != null ? 
                   jsonEncode(ficheData['donnees']) : null,
        'etat_de_la_fiche': ficheData['etat_de_la_fiche'],
        
        // Entêtes values (format JSON pour le serializer)
        'entete_values': jsonEncode(enteteValues),
        
        // Anomalies (optionnel, format JSON)
        if (anomalies != null && anomalies.isNotEmpty)
          'anomalies': jsonEncode(anomalies),
      });

      // Log des données FormData avant fichiers
      print('📋 FORM DATA (avant fichiers):');
      form.fields.forEach((entry) {
        print('  ${entry.key}: ${entry.value} (${entry.value.runtimeType})');
      });      // Ajouter la photo obligatoire
      form.files.add(MapEntry(
        'photo',
        MultipartFile(
          photoObligatoire, 
          filename: 'photo_controle_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      ));

      // Ajouter la signature du qualiticient
      form.files.add(MapEntry(
        'signature_qualiticient',
        MultipartFile(
          signatureQualiticient, 
          filename: 'signature_${DateTime.now().millisecondsSinceEpoch}.png',
        ),
      ));

      // Log des fichiers
      print('� FICHIERS AJOUTÉS:');
      form.files.forEach((entry) {
        print('  ${entry.key}: ${entry.value.filename} (${entry.value.length} bytes)');
      });

      print('🌐 URL ENDPOINT: ${httpClient.baseUrl}/fiche-controle-remplie/create/');
      print('🔐 TOKEN: ${_authService.token != null ? "✅ Présent" : "❌ Absent"}');

      // Envoi de la requête
      print('🚀 ENVOI DE LA REQUÊTE...');
      final response = await post('/fiche-controle-remplie/create/', form);

      print('📡 RÉPONSE REÇUE:');
      print('  📊 Status Code: ${response.statusCode}');
      print('  📊 Status Text: ${response.statusText}');
      print('  📊 Headers: ${response.headers}');
      print('  📊 Body Type: ${response.body.runtimeType}');
      print('  📊 Body Content: ${response.body}');

      if (response.hasError) {
        print('❌ ERREUR HTTP DÉTECTÉE:');
        print('  🔢 Status Code: ${response.statusCode}');
        print('  📋 Response body: ${response.body}');
        
        String errorMessage = 'Erreur lors de la création de la fiche';
        
        if (response.body is Map && response.body.containsKey('detail')) {
          errorMessage = response.body['detail'];
        } else if (response.body is Map && response.body.containsKey('error')) {
          errorMessage = response.body['error'];
        } else if (response.statusText != null) {
          errorMessage = response.statusText!;
        }
        
        print('  💬 Message d\'erreur final: $errorMessage');
        throw Exception(errorMessage);
      }

      print('✅ Fiche contrôle créée avec succès');
      print('📊 Response: ${response.body}');
      print('🔥🔥🔥 === FIN LOGS DÉTAILLÉS === 🔥🔥🔥');
      
      return Map<String, dynamic>.from(response.body);
      
    } catch (e) {
      print('❌ EXCEPTION CAPTURÉE: $e');
      print('🔥🔥🔥 === FIN LOGS DÉTAILLÉS (ERREUR) === 🔥🔥🔥');
      rethrow;
    }
  }

  /// Récupérer une fiche de contrôle par ID
  Future<Map<String, dynamic>> getFicheControle(int ficheId) async {
    try {
      final response = await get('/fiche-controle-remplie/$ficheId/');
      
      if (response.hasError) {
        throw Exception('Erreur lors de la récupération: ${response.statusText}');
      }
      
      return Map<String, dynamic>.from(response.body);
      
    } catch (e) {
      print('❌ Erreur lors de la récupération de la fiche: $e');
      rethrow;
    }
  }

  /// Lister les fiches de contrôle de l'utilisateur
  Future<List<Map<String, dynamic>>> getFichesControle({
    int? activiteSpecifiqueId,
    String? etat,
  }) async {
    try {
      Map<String, dynamic> queryParams = {};
      
      if (activiteSpecifiqueId != null) {
        queryParams['activite_specifique'] = activiteSpecifiqueId.toString();
      }
      
      if (etat != null) {
        queryParams['etat_de_la_fiche'] = etat;
      }
      
      final response = await get('/fiche-controle-remplie/', query: queryParams);
      
      if (response.hasError) {
        throw Exception('Erreur lors de la récupération: ${response.statusText}');
      }
      
      if (response.body['results'] != null) {
        return List<Map<String, dynamic>>.from(response.body['results']);
      }
      
      return [];
      
    } catch (e) {
      print('❌ Erreur lors de la récupération des fiches: $e');
      rethrow;
    }
  }
}



extension JsonEncode on FicheControleService {
  String jsonEncode(dynamic object) {
    return const JsonEncoder().convert(object);
  }
}
