import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../config/config.dart';

class AuthService extends GetConnect {
  static AuthService get to => Get.find<AuthService>();

  final RxBool isLoggedIn = false.obs;
  final RxnString userRole = RxnString(); // ✅ Peut être null
  final RxnString _token = RxnString(); // ✅ Token sécurisé avec getter
  final RxnString _refreshToken = RxnString(); // ✅ Refresh token sécurisé avec getter

  String? get token => _token.value;

  Future<AuthService> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token.value = prefs.getString('token');
    _refreshToken.value = prefs.getString('refresh_token');
    userRole.value = prefs.getString('role');

    print("Token récupéré: $_token");
    print("Refresh token récupéré: $_refreshToken");
    print("Rôle récupéré: $userRole");

    // Vérifie si le token est valide et non expiré
    isLoggedIn.value = _token.value != null && !isTokenExpired(_token.value);
    return this;
  }

  // Vérifie si le token est expiré
  bool isTokenExpired(String? token) {
    if (token == null) return true;

    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;

      final payload = _decodeBase64(parts[1]);
      final payloadMap = json.decode(payload);
      final exp = payloadMap['exp'] as int;

      final currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      return exp <= currentTime;
    } catch (e) {
      return true;
    }
  }

  // Décode une chaîne base64
  String _decodeBase64(String str) {
    String output = str.replaceAll('-', '+').replaceAll('_', '/');
    switch (output.length % 4) {
      case 0:
        break;
      case 2:
        output += '==';
        break;
      case 3:
        output += '=';
        break;
      default:
        throw Exception('Invalid base64 string');
    }
    return utf8.decode(base64Url.decode(output));
  }

  Future<bool> login(String email, String password) async {
    try {
      final response = await post(
        "${AppConfig.baseUrl}/token/",
        jsonEncode({"email": email, "password": password}), // ✅ Encodage JSON
        headers: {"Content-Type": "application/json"},
      );

      if (response.status.hasError) {
        print("Erreur de connexion: ${response.statusText}");
        return false;
      }

      final body = response.body;
      if (body == null || !body.containsKey('access')) {
        print("Réponse invalide de l'API: $body");
        return false;
      }

      // Vérifie si 'role' existe avant de l'utiliser
      String? role = body.containsKey('role') ? body['role'] : null;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', body['access']);
      await prefs.setString('refresh_token', body['refresh']); // Stocke le refresh token
      if (role != null) {
        await prefs.setString('role', role);
      }

      _token.value = body['access'];
      _refreshToken.value = body['refresh'];
      userRole.value = role;
      isLoggedIn.value = true;

      // Vérifie si l'utilisateur doit changer son mot de passe
      if (body.containsKey('force_password_change') && body['force_password_change'] == true) {
        Get.offAllNamed('/password-change'); // Navigation par route
      } else {
        Get.offAllNamed('/home'); // Navigation vers l'écran principal
      }

      return true;
    } catch (e) {
      print("Exception lors de la connexion: $e");
      return false;
    }
  }

  // Rafraîchit le token d'accès
  Future<bool> refreshToken() async {
    try {
      if (_refreshToken.value == null) {
        print("Refresh token non disponible");
        return false;
      }

      final response = await post(
        "${AppConfig.baseUrl}/token/refresh/",
        jsonEncode({"refresh": _refreshToken.value}),
        headers: {"Content-Type": "application/json"},
      );

      if (response.status.hasError) {
        print("Erreur lors du rafraîchissement du token: ${response.statusText}");
        return false;
      }

      final body = response.body;
      if (body == null || !body.containsKey('access')) {
        print("Réponse invalide de l'API: $body");
        return false;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', body['access']);
      _token.value = body['access'];

      print("Token rafraîchi avec succès");
      return true;
    } catch (e) {
      print("Exception lors du rafraîchissement du token: $e");
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('refresh_token');
    await prefs.remove('role');

    _token.value = null;
    _refreshToken.value = null;
    userRole.value = null;
    isLoggedIn.value = false;

    Get.offAllNamed('/splash'); // ✅ Rediriger après déconnexion
  }

  Map<String, String> getAuthHeaders() {
    return {
      "Authorization": "Bearer ${_token.value ?? ''}",
      "Content-Type": "application/json",
    };
  }

  Future<Response> getUserProfile() async {
    if (_token.value == null || isTokenExpired(_token.value)) {
      if (!await refreshToken()) {
        await logout(); // Déconnecte l'utilisateur si le rafraîchissement échoue
        return Response(statusCode: 401, body: "Unauthorized");
      }
    }

    return await get(
      "${AppConfig.baseUrl}/users/detail/",
      headers: getAuthHeaders(),
    );
  }
}
