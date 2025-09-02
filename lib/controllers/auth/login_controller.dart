import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../services/auth/auth_service.dart';

class LoginController extends GetxController {
  // Controllers pour les champs de texte
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  
  // Observable pour l'état de chargement
  var isLoading = false.obs;
  
  // Observable pour la visibilité du mot de passe
  var isPasswordVisible = false.obs;

  // Instance d'AuthService
  final AuthService _authService = Get.find<AuthService>();

  @override
  void onClose() {
    // Nettoie les controllers quand le controller est détruit
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  // Méthode pour basculer la visibilité du mot de passe
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  // Méthode de connexion
  Future<void> login() async {
    if (_validateInputs()) {
      isLoading.value = true;
      
      try {
        // Appel de l'AuthService pour la connexion
        final success = await _authService.login(
          emailController.text.trim(),
          passwordController.text.trim(),
        );
        
        if (success) {
          // Connexion réussie - le middleware redirigera automatiquement
          Get.offAllNamed('/home');
          Get.snackbar(
            'Succès',
            'Connexion réussie',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } else {
          // Échec de connexion
          Get.snackbar(
            'Erreur',
            'Email ou mot de passe incorrect',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } catch (e) {
        // Erreur réseau ou autre
        Get.snackbar(
          'Erreur',
          'Erreur de connexion: ${e.toString()}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } finally {
        isLoading.value = false;
      }
    }
  }

  // Validation des champs
  bool _validateInputs() {
    if (emailController.text.trim().isEmpty) {
      Get.snackbar(
        'Erreur',
        'Veuillez saisir votre email',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    if (!GetUtils.isEmail(emailController.text.trim())) {
      Get.snackbar(
        'Erreur',
        'Veuillez saisir un email valide',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    if (passwordController.text.trim().isEmpty) {
      Get.snackbar(
        'Erreur',
        'Veuillez saisir votre mot de passe',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    return true;
  }
}
