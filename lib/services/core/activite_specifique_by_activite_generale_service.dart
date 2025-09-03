import 'package:get/get.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../config/config.dart';
import '../auth/auth_service.dart';

class ActiviteSpecifiqueByActiviteGeneraleService extends GetConnect {
  static ActiviteSpecifiqueByActiviteGeneraleService get to => Get.find<ActiviteSpecifiqueByActiviteGeneraleService>();

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
      } else {
        print("❌ Token non disponible pour la requête API");
      }
      return request;
    });
    
    super.onInit();
  }

  /// 🔍 Méthode utilitaire pour déboguer le token (développement uniquement)
  Future<void> debugToken() async {
    final authService = Get.find<AuthService>();
    final token = authService.token;

    if (token != null && token.isNotEmpty) {
      try {
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        print("📌 Contenu du token : $decodedToken");
        
        if (decodedToken.containsKey("role")) {
          print("👤 Rôle utilisateur : ${decodedToken["role"]}");
        } else {
          print("❌ Le rôle n'est pas présent dans le token !");
        }
      } catch (e) {
        print("❌ Erreur lors du décodage du token : $e");
      }
    } else {
      print("❌ Aucun token trouvé !");
    }
  }

  /// 🔹 Méthode générique pour les appels API avec gestion d'erreurs optimisée
  Future<List<dynamic>> _makeApiCall(String endpoint, {String? debugMessage}) async {
    try {
      final response = await get(endpoint);
      
      if (debugMessage != null) {
        print("📡 $debugMessage : ${response.statusCode}");
      }

      if (response.statusCode == 200) {
        final data = response.body;
        return data is List ? data : (data != null ? [data] : []);
      } else if (response.statusCode == 401) {
        print("🔒 Token expiré ou invalide - Redirection vers login nécessaire");
        final authService = Get.find<AuthService>();
        await authService.logout();
        return [];
      } else {
        print("❌ Erreur ${response.statusCode} : ${response.statusText}");
        return [];
      }
    } catch (e) {
      print("⚠️ Exception lors de l'appel API [$endpoint] : $e");
      return [];
    }
  }

  /// 🔹 Récupérer les activités spécifiques par activité générale
  Future<List<dynamic>> getActivitesSpecifiquesByActiviteGenerale(int activiteGeneraleId) async {
    if (activiteGeneraleId <= 0) {
      print("❌ ID d'activité générale invalide : $activiteGeneraleId");
      return [];
    }

    return await _makeApiCall(
      "/activites-specifiques/activite-generale/$activiteGeneraleId/",
      debugMessage: "Récupération activités spécifiques pour activité générale $activiteGeneraleId",
    );
  }

  /// 🔹 Récupérer toutes les activités spécifiques
  Future<List<dynamic>> getAllActivitesSpecifiques() async {
    return await _makeApiCall(
      "/activites-specifiques/list/",
      debugMessage: "Récupération de toutes les activités spécifiques",
    );
  }

  /// 🔹 Récupérer une activité spécifique par ID
  Future<Map<String, dynamic>?> getActiviteSpecifiqueById(int id) async {
    if (id <= 0) {
      print("❌ ID d'activité spécifique invalide : $id");
      return null;
    }

    try {
      final response = await get("/activites-specifiques/$id/");
      
      print("📡 Récupération activité spécifique $id : ${response.statusCode}");

      if (response.statusCode == 200) {
        return response.body;
      } else if (response.statusCode == 401) {
        final authService = Get.find<AuthService>();
        await authService.logout();
        return null;
      } else {
        print("❌ Erreur ${response.statusCode} : ${response.statusText}");
        return null;
      }
    } catch (e) {
      print("⚠️ Exception lors de la récupération : $e");
      return null;
    }
  }

  /// 🔹 Créer une nouvelle activité spécifique
  Future<Map<String, dynamic>?> createActiviteSpecifique(Map<String, dynamic> data) async {
    try {
      final response = await post("/activites-specifiques/", data);
      
      print("📡 Création activité spécifique : ${response.statusCode}");

      if (response.statusCode == 201) {
        return response.body;
      } else if (response.statusCode == 401) {
        final authService = Get.find<AuthService>();
        await authService.logout();
        return null;
      } else {
        print("❌ Erreur création : ${response.statusCode} - ${response.statusText}");
        return null;
      }
    } catch (e) {
      print("⚠️ Exception lors de la création : $e");
      return null;
    }
  }

  /// 🔹 Mettre à jour une activité spécifique
  Future<Map<String, dynamic>?> updateActiviteSpecifique(int id, Map<String, dynamic> data) async {
    if (id <= 0) {
      print("❌ ID d'activité spécifique invalide : $id");
      return null;
    }

    try {
      final response = await put("/activites-specifiques/$id/", data);
      
      print("📡 Mise à jour activité spécifique $id : ${response.statusCode}");

      if (response.statusCode == 200) {
        return response.body;
      } else if (response.statusCode == 401) {
        final authService = Get.find<AuthService>();
        await authService.logout();
        return null;
      } else {
        print("❌ Erreur mise à jour : ${response.statusCode} - ${response.statusText}");
        return null;
      }
    } catch (e) {
      print("⚠️ Exception lors de la mise à jour : $e");
      return null;
    }
  }

  /// 🔹 Supprimer une activité spécifique
  Future<bool> deleteActiviteSpecifique(int id) async {
    if (id <= 0) {
      print("❌ ID d'activité spécifique invalide : $id");
      return false;
    }

    try {
      final response = await delete("/activites-specifiques/$id/");
      
      print("📡 Suppression activité spécifique $id : ${response.statusCode}");

      if (response.statusCode == 204 || response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401) {
        final authService = Get.find<AuthService>();
        await authService.logout();
        return false;
      } else {
        print("❌ Erreur suppression : ${response.statusCode} - ${response.statusText}");
        return false;
      }
    } catch (e) {
      print("⚠️ Exception lors de la suppression : $e");
      return false;
    }
  }
}