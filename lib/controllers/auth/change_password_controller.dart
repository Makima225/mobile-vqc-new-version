import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../services/auth/auth_service.dart';
import '../../config/config.dart';

class ChangePasswordController extends GetxController {
  final AuthService _authService = AuthService.to;
  
  // Controllers pour les champs de texte
  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  
  // Observable pour l'état de chargement
  var isLoading = false.obs;
  
  // Observables pour la visibilité des mots de passe
  var isCurrentPasswordVisible = false.obs;
  var isNewPasswordVisible = false.obs;
  var isConfirmPasswordVisible = false.obs;

  @override
  void onClose() {
    // Nettoie les controllers quand le controller est détruit
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  // Méthodes pour basculer la visibilité des mots de passe
  void toggleCurrentPasswordVisibility() {
    isCurrentPasswordVisible.value = !isCurrentPasswordVisible.value;
  }

  void toggleNewPasswordVisibility() {
    isNewPasswordVisible.value = !isNewPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  // Méthode pour changer le mot de passe
  void changePassword() {
    if (_validateInputs()) {
      _changePasswordAPI(
        currentPasswordController.text.trim(),
        newPasswordController.text.trim(),
      );
    }
  }

  // Appel API pour changer le mot de passe
  Future<void> _changePasswordAPI(String oldPassword, String newPassword) async {
    try {
      isLoading.value = true;

      final response = await _authService.put(
        "${AppConfig.baseUrl}/users/change-password/",
        jsonEncode({
          "old_password": oldPassword,
          "new_password": newPassword,
        }),
        headers: _authService.getAuthHeaders(),
      );

      if (response.status.hasError) {
        Get.snackbar(
          'Erreur', 
          'Échec du changement de mot de passe',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        return;
      }

      // Succès
      Get.snackbar(
        'Succès', 
        'Mot de passe changé avec succès',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      
      // Navigation vers l'écran principal
      Get.offAllNamed('/home');

    } catch (e) {
      Get.snackbar(
        'Erreur', 
        'Une erreur s\'est produite',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      print('Erreur changement mot de passe: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Validation des champs
  bool _validateInputs() {
    if (currentPasswordController.text.trim().isEmpty) {
      _showError('Veuillez saisir votre mot de passe actuel');
      return false;
    }

    if (newPasswordController.text.trim().isEmpty) {
      _showError('Veuillez saisir votre nouveau mot de passe');
      return false;
    }

    if (newPasswordController.text.trim().length < 6) {
      _showError('Le nouveau mot de passe doit contenir au moins 6 caractères');
      return false;
    }

    if (confirmPasswordController.text.trim().isEmpty) {
      _showError('Veuillez confirmer votre nouveau mot de passe');
      return false;
    }

    if (newPasswordController.text.trim() != confirmPasswordController.text.trim()) {
      _showError('Les mots de passe ne correspondent pas');
      return false;
    }

    if (currentPasswordController.text.trim() == newPasswordController.text.trim()) {
      _showError('Le nouveau mot de passe doit être différent de l\'ancien');
      return false;
    }

    return true;
  }

  // Méthode pour afficher les erreurs
  void _showError(String message) {
    Get.snackbar(
      'Erreur',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  // Méthode pour annuler et retourner
  void cancel() {
    Get.back();
  }
}
