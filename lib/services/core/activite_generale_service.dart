import 'package:get/get.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../config/config.dart';
import '../auth/auth_service.dart';

class ActiviteGeneraleService extends GetConnect {
  static ActiviteGeneraleService get to => Get.find<ActiviteGeneraleService>();

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
      print("🚀 Appel API vers: ${httpClient.baseUrl}$endpoint");
      final response = await get(endpoint);
      
      if (debugMessage != null) {
        print("📡 $debugMessage : ${response.statusCode}");
      }

      if (response.statusCode == 200) {
        final data = response.body;
        print("✅ Données reçues: ${data is List ? data.length : 1} éléments");
        if (data is List && data.isNotEmpty) {
          print("📋 Premier élément: ${data.first}");
        }
        return data is List ? data : (data != null ? [data] : []);
      } else if (response.statusCode == 401) {
        print("🔒 Token expiré ou invalide - Redirection vers login nécessaire");
        final authService = Get.find<AuthService>();
        await authService.logout();
        return [];
      } else {
        print("❌ Erreur ${response.statusCode} : ${response.statusText}");
        print("📄 Réponse complète: ${response.body}");
        return [];
      }
    } catch (e) {
      print("⚠️ Exception lors de l'appel API [$endpoint] : $e");
      return [];
    }
  }

  /// 🔹 Récupérer les activités générales liées aux ingénieurs travaux
  Future<List<dynamic>> getActivitesGenerales() async {
    return await _makeApiCall(
      "/activite-generales/ingenieur-travaux/",
      debugMessage: "Récupération activités générales ingénieurs",
    );
  }

  /// 🔹 Récupérer les activités générales liées aux qualiticiens connectés
  Future<List<dynamic>> getActivitesGeneralesByQualiticient() async {
    return await _makeApiCall(
      "/activite-generales/qualiticient/",
      debugMessage: "Récupération activités générales qualiticiens connectés",
    );
  }

  /// 🔹 Récupérer les activités générales pour un sous-projet spécifique
  Future<List<dynamic>> getActivitesGeneralesBySousProjet(int sousProjetId) async {
    if (sousProjetId <= 0) {
      print("❌ ID de sous-projet invalide : $sousProjetId");
      return [];
    }

    return await _makeApiCall(
      "/activites-generales/by-sous-projet/$sousProjetId/",
      debugMessage: "Récupération activités pour sous-projet $sousProjetId",
    );
  }

  /// 🔹 Créer une nouvelle activité générale
  Future<Map<String, dynamic>?> createActiviteGenerale(Map<String, dynamic> data) async {
    try {
      final response = await post("/activite-generales/", data);
      
      print("📡 Création activité générale : ${response.statusCode}");

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

  /// 🔹 Mettre à jour une activité générale
  Future<Map<String, dynamic>?> updateActiviteGenerale(int id, Map<String, dynamic> data) async {
    if (id <= 0) {
      print("❌ ID d'activité invalide : $id");
      return null;
    }

    try {
      final response = await put("/activite-generales/$id/", data);
      
      print("📡 Mise à jour activité $id : ${response.statusCode}");

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

  /// 🔹 Supprimer une activité générale
  Future<bool> deleteActiviteGenerale(int id) async {
    if (id <= 0) {
      print("❌ ID d'activité invalide : $id");
      return false;
    }

    try {
      final response = await delete("/activite-generales/$id/");
      
      print("📡 Suppression activité $id : ${response.statusCode}");

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

 