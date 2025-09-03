import 'package:get/get.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../config/config.dart';
import '../auth/auth_service.dart';

class TemplateFichecontroleByActiviteSpecifiqueService extends GetConnect {
  static TemplateFichecontroleByActiviteSpecifiqueService get to => Get.find<TemplateFichecontroleByActiviteSpecifiqueService>();

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

  /// 🔹 Récupérer les templates fiche contrôle liés à une activité spécifique
  Future<List<dynamic>> getTemplatesByActiviteSpecifique(int activiteSpecifiqueId) async {
    if (activiteSpecifiqueId <= 0) {
      print("❌ ID d'activité spécifique invalide : $activiteSpecifiqueId");
      return [];
    }

    return await _makeApiCall(
      "/templates-fichecontrole/by-activite-specifique/$activiteSpecifiqueId/",
      debugMessage: "Récupération templates pour activité spécifique $activiteSpecifiqueId",
    );
  }

  /// 🔹 Créer un nouveau template fiche contrôle
  Future<Map<String, dynamic>?> createTemplateFichecontrole(Map<String, dynamic> data) async {
    try {
      final response = await post("/templates-fichecontrole/", data);
      
      print("📡 Création template fiche contrôle : ${response.statusCode}");

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

  /// 🔹 Mettre à jour un template fiche contrôle
  Future<Map<String, dynamic>?> updateTemplateFichecontrole(int id, Map<String, dynamic> data) async {
    if (id <= 0) {
      print("❌ ID de template invalide : $id");
      return null;
    }

    try {
      final response = await put("/templates-fichecontrole/$id/", data);
      
      print("📡 Mise à jour template $id : ${response.statusCode}");

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

  /// 🔹 Supprimer un template fiche contrôle
  Future<bool> deleteTemplateFichecontrole(int id) async {
    if (id <= 0) {
      print("❌ ID de template invalide : $id");
      return false;
    }

    try {
      final response = await delete("/templates-fichecontrole/$id/");
      
      print("📡 Suppression template $id : ${response.statusCode}");

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

  /// 🔹 Récupérer un template spécifique par son ID
  Future<Map<String, dynamic>?> getTemplateFichecontroleById(int id) async {
    if (id <= 0) {
      print("❌ ID de template invalide : $id");
      return null;
    }

    try {
      print("🚀 Appel API vers: ${httpClient.baseUrl}/templates-fichecontrole/$id/");
      final response = await get("/templates-fichecontrole/detail/$id/");
      
      print("📡 Récupération template $id : ${response.statusCode}");

      if (response.statusCode == 200) {
        return response.body;
      } else if (response.statusCode == 401) {
        final authService = Get.find<AuthService>();
        await authService.logout();
        return null;
      } else if (response.statusCode == 404) {
        print("❌ Template non trouvé : ID $id");
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

  /// 🔹 Télécharger un fichier template
  Future<Response?> downloadTemplateFichier(String fichierUrl) async {
    try {
      print("🚀 Téléchargement fichier: $fichierUrl");
      
      // Construire l'URL complète si nécessaire
      final fullUrl = fichierUrl.startsWith('http') 
          ? fichierUrl 
          : '${httpClient.baseUrl}$fichierUrl';
      
      final response = await get(fullUrl);
      
      print("📡 Téléchargement fichier : ${response.statusCode}");

      if (response.statusCode == 200) {
        return response;
      } else if (response.statusCode == 401) {
        final authService = Get.find<AuthService>();
        await authService.logout();
        return null;
      } else {
        print("❌ Erreur téléchargement : ${response.statusCode} - ${response.statusText}");
        return null;
      }
    } catch (e) {
      print("⚠️ Exception lors du téléchargement : $e");
      return null;
    }
  }

  /// 🔹 Vérifier la disponibilité d'un template
  Future<bool> isTemplateAvailable(int activiteSpecifiqueId) async {
    final templates = await getTemplatesByActiviteSpecifique(activiteSpecifiqueId);
    return templates.isNotEmpty;
  }

  /// 🔹 Compter le nombre de templates pour une activité spécifique
  Future<int> countTemplatesByActiviteSpecifique(int activiteSpecifiqueId) async {
    final templates = await getTemplatesByActiviteSpecifique(activiteSpecifiqueId);
    return templates.length;
  }
}