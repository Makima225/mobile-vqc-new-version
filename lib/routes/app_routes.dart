import 'package:get/get.dart';
import '../views/splash_screen.dart';
import '../views/auth/login_screen.dart';
import '../views/auth/change_password_screen.dart';
import '../modules/bottomNavigationBar/views/bottom_nav_selector.dart';
import '../middlewares/auth_middleware.dart';

class AppRoutes {
  // Routes principales
  static const String splashView = '/';
  static const String home = '/home';
  static const String login = '/login';
  static const String passwordChange = '/passwordChange';
  
  static final routes = [
    // Route de démarrage
    GetPage(
      name: splashView, 
      page: () => const SplashScreen(),
    ),
    
    // Route principale avec navigation conditionnelle (BottomNavSelector gère le reste)
    GetPage(
      name: home,
      page: () => BottomNavSelector(),
      middlewares: [AuthMiddleware()],
    ),
    
    // Routes d'authentification
    GetPage(
      name: login, 
      page: () => const LoginScreen(),
    ),
    GetPage(
      name: passwordChange, 
      page: () => const ChangePasswordScreen(),
      middlewares: [AuthMiddleware()],
    ),
  ];
}
