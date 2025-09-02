import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/config.dart';
import '../../models/core/sous_projet_model.dart';
import '../auth/auth_service.dart';

class SousProjetService extends GetConnect {
  static SousProjetService get to => Get.find<SousProjetService>();
  
  final AuthService _authService = Get.find<AuthService>();

  @override
  void onInit() {
    // Utilisation de la configuration centralisée
    httpClient.baseUrl = AppConfig.baseUrl;
    
    // Intercepteur pour ajouter automatiquement le token
    httpClient.addRequestModifier<dynamic>((request) async {
      final headers = _authService.getAuthHeaders();
      request.headers.addAll(headers);
      
      print("🚀 Requête ${request.method} vers: ${request.url}");
      print("📡 Headers: ${request.headers}");
      
      return request;
    });

    // Intercepteur pour gérer les réponses
    httpClient.addResponseModifier((request, response) {
      print("📥 Réponse ${response.statusCode} de: ${request.url}");
      
      if (response.statusCode == 401) {
        print("❌ Token expiré, tentative de rafraîchissement...");
        _authService.refreshToken();
      }
      
      return response;
    });
    
    super.onInit();
  }

  // 🔍 Vérifier et afficher le contenu du token
  Future<void> debugToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null) {
      try {
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        print("📌 Contenu du token : $decodedToken");

        if (decodedToken.containsKey("role")) {
          print("👤 Rôle utilisateur : ${decodedToken["role"]}");
        } else {
          print("❌ Le rôle n'est pas présent dans le token !");
        }
        
        // Vérification de l'expiration
        if (JwtDecoder.isExpired(token)) {
          print("⚠️ Token expiré !");
          await _authService.refreshToken();
        }
      } catch (e) {
        print("❌ Erreur lors du décodage du token: $e");
      }
    } else {
      print("❌ Aucun token trouvé !");
    }
  }

  // 🔹 Récupérer tous les sous-projets
  Future<List<SousProjet>> getAllSousProjets() async {
    await debugToken();

    try {
      final response = await get("/sous-projets/list/");
      
      print("📡 Réponse API tous sous-projets: ${response.statusCode}");

      if (response.statusCode == 200) {
        final List<dynamic> data = response.body ?? [];
        return data.map((json) => SousProjet.fromJson(json)).toList();
      } else {
        _handleError(response);
        return [];
      }
    } catch (e) {
      print("⚠️ Exception dans getAllSousProjets: $e");
      Get.snackbar('Erreur', 'Impossible de récupérer les sous-projets');
      return [];
    }
  }

  // 🔹 Récupérer les sous-projets liés au qualiticien connecté
  Future<List<SousProjet>> getSousProjetsForQualiticien() async {
    await debugToken();

    try {
      final response = await get("/sous-projets/qualiticient/");
      
      print("📡 Réponse API sous-projets qualiticien: ${response.statusCode}");

      if (response.statusCode == 200) {
        final List<dynamic> data = response.body ?? [];
        return data.map((json) => SousProjet.fromJson(json)).toList();
      } else {
        _handleError(response);
        return [];
      }
    } catch (e) {
      print("⚠️ Exception dans getSousProjetsForQualiticien: $e");
      Get.snackbar('Erreur', 'Impossible de récupérer vos sous-projets');
      return [];
    }
  }

  // 🔹 Récupérer les sous-projets liés à un ingénieur travaux
  Future<List<SousProjet>> getSousProjetsForIngenieur() async {
    await debugToken();

    try {
      final response = await get("/sub-project/ingenieur/");
      
      print("📡 Réponse API sous-projets ingénieur: ${response.statusCode}");

      if (response.statusCode == 200) {
        final List<dynamic> data = response.body ?? [];
        return data.map((json) => SousProjet.fromJson(json)).toList();
      } else {
        _handleError(response);
        return [];
      }
    } catch (e) {
      print("⚠️ Exception dans getSousProjetsForIngenieur: $e");
      Get.snackbar('Erreur', 'Impossible de récupérer les sous-projets');
      return [];
    }
  }

  // 🔹 Récupérer les détails d'un sous-projet spécifique
  Future<SousProjet?> getSousProjetDetails(int sousProjetId) async {
    await debugToken();
    
    try {
      final response = await get("/sous-projets/detail/$sousProjetId/");

      print("📡 Réponse API détails sous-projet: ${response.statusCode}");

      if (response.statusCode == 200) {
        return SousProjet.fromJson(response.body);
      } else {
        _handleError(response);
        return null;
      }
    } catch (e) {
      print("⚠️ Exception dans getSousProjetDetails: $e");
      Get.snackbar('Erreur', 'Impossible de récupérer les détails du sous-projet');
      return null;
    }
  }

  // 🔹 Créer un nouveau sous-projet
  Future<SousProjet?> createSousProjet(SousProjet sousProjet) async {
    await debugToken();

    try {
      final response = await post(
        "/sous-projets/",
        sousProjet.toJson(),
      );

      print("📡 Réponse API création sous-projet: ${response.statusCode}");

      if (response.statusCode == 201) {
        Get.snackbar('Succès', 'Sous-projet créé avec succès');
        return SousProjet.fromJson(response.body);
      } else {
        _handleError(response);
        return null;
      }
    } catch (e) {
      print("⚠️ Exception dans createSousProjet: $e");
      Get.snackbar('Erreur', 'Impossible de créer le sous-projet');
      return null;
    }
  }

  // 🔹 Mettre à jour un sous-projet
  Future<SousProjet?> updateSousProjet(int id, SousProjet sousProjet) async {
    await debugToken();

    try {
      final response = await put(
        "/sous-projets/$id/",
        sousProjet.toJson(),
      );

      print("📡 Réponse API mise à jour sous-projet: ${response.statusCode}");

      if (response.statusCode == 200) {
        Get.snackbar('Succès', 'Sous-projet mis à jour avec succès');
        return SousProjet.fromJson(response.body);
      } else {
        _handleError(response);
        return null;
      }
    } catch (e) {
      print("⚠️ Exception dans updateSousProjet: $e");
      Get.snackbar('Erreur', 'Impossible de mettre à jour le sous-projet');
      return null;
    }
  }

  // 🔹 Supprimer un sous-projet
  Future<bool> deleteSousProjet(int id) async {
    await debugToken();

    try {
      final response = await delete("/sous-projets/$id/");

      print("📡 Réponse API suppression sous-projet: ${response.statusCode}");

      if (response.statusCode == 204) {
        Get.snackbar('Succès', 'Sous-projet supprimé avec succès');
        return true;
      } else {
        _handleError(response);
        return false;
      }
    } catch (e) {
      print("⚠️ Exception dans deleteSousProjet: $e");
      Get.snackbar('Erreur', 'Impossible de supprimer le sous-projet');
      return false;
    }
  }

  // 🛠️ Gestion centralisée des erreurs
  void _handleError(Response response) {
    String errorMessage;
    
    switch (response.statusCode) {
      case 400:
        errorMessage = 'Données invalides';
        break;
      case 401:
        errorMessage = 'Non autorisé - Veuillez vous reconnecter';
        break;
      case 403:
        errorMessage = 'Accès interdit';
        break;
      case 404:
        errorMessage = 'Ressource non trouvée';
        break;
      case 500:
        errorMessage = 'Erreur serveur';
        break;
      default:
        errorMessage = 'Erreur inconnue (${response.statusCode})';
    }
    
    print("❌ Erreur ${response.statusCode} : $errorMessage");
    print("📄 Détails: ${response.body}");
    
    Get.snackbar(
      'Erreur',
      errorMessage,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
}