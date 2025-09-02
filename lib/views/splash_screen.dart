import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/splash_screen_controller.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialisation du controller
    final SplashScreenController controller = Get.put(SplashScreenController());
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Titre principal
            const Text(
              'Quality Control',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
                letterSpacing: 1.2,
              ),
            ),
            
            const SizedBox(height: 60),
            
            // Loader avec observateur
            Obx(() => controller.isLoading.value
                ? Column(
                    children: [
                      // Indicateur de chargement circulaire
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                        strokeWidth: 3,
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Texte de chargement
                      const Text(
                        'Chargement...',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  )
                : const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 60,
                  )),
          ],
        ),
      ),
    );
  }
}
