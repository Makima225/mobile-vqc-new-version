import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth/change_password_controller.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialisation du controller
    final ChangePasswordController controller = Get.put(ChangePasswordController());
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Changer le mot de passe'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: controller.cancel,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              
              // Instructions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade600),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Pour votre sécurité, veuillez saisir votre mot de passe actuel puis choisir un nouveau mot de passe.',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Champ mot de passe actuel
              const Text(
                'Mot de passe actuel',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Obx(() => TextField(
                controller: controller.currentPasswordController,
                obscureText: !controller.isCurrentPasswordVisible.value,
                decoration: InputDecoration(
                  hintText: 'Saisissez votre mot de passe actuel',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.isCurrentPasswordVisible.value
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: controller.toggleCurrentPasswordVisibility,
                  ),
                ),
              )),
              
              const SizedBox(height: 24),
              
              // Champ nouveau mot de passe
              const Text(
                'Nouveau mot de passe',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Obx(() => TextField(
                controller: controller.newPasswordController,
                obscureText: !controller.isNewPasswordVisible.value,
                decoration: InputDecoration(
                  hintText: 'Saisissez votre nouveau mot de passe',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.isNewPasswordVisible.value
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: controller.toggleNewPasswordVisibility,
                  ),
                ),
              )),
              
              const SizedBox(height: 8),
              Text(
                'Minimum 6 caractères',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Champ confirmation mot de passe
              const Text(
                'Confirmer le nouveau mot de passe',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Obx(() => TextField(
                controller: controller.confirmPasswordController,
                obscureText: !controller.isConfirmPasswordVisible.value,
                decoration: InputDecoration(
                  hintText: 'Confirmez votre nouveau mot de passe',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock_reset),
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.isConfirmPasswordVisible.value
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: controller.toggleConfirmPasswordVisibility,
                  ),
                ),
              )),
              
              const SizedBox(height: 40),
              
              // Boutons d'action
              Row(
                children: [
                  // Bouton Annuler
                  Expanded(
                    child: OutlinedButton(
                      onPressed: controller.cancel,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey.shade700,
                        side: BorderSide(color: Colors.grey.shade400),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Annuler',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Bouton Changer
                  Expanded(
                    flex: 2,
                    child: Obx(() => ElevatedButton(
                      onPressed: controller.isLoading.value ? null : controller.changePassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: controller.isLoading.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Changer le mot de passe',
                              style: TextStyle(fontSize: 16),
                            ),
                    )),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
