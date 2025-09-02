import 'package:get/get.dart';

class SplashScreenController extends GetxController {
  // Observable pour l'état du loading
  var isLoading = true.obs;
  
  @override
  void onInit() {
    super.onInit();
    _startSplashTimer();
  }
  
  void _startSplashTimer() {
    // Timer de 5 secondes
    Future.delayed(const Duration(seconds: 5), () {
      isLoading.value = false;
      // Navigation vers la page suivante (à définir plus tard)
      _navigateToNextScreen();
    });
  }
  
  void _navigateToNextScreen() {
    // Navigation vers la page d'accueil
    Get.offNamed('/home');
  }
}
