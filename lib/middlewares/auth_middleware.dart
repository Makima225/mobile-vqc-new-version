import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:mobile_vqc_new_version/routes/app_routes.dart';
import 'package:mobile_vqc_new_version/services/auth/auth_service.dart';



class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final authService = Get.find<AuthService>();

    // Redirige vers la page de connexion si l'utilisateur n'est pas connecté
    return authService.isLoggedIn.value ? null : const RouteSettings(name: AppRoutes.login);
  }
}