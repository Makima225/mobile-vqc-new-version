import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/ingenieur_nav_controller.dart';

class IngenieurNavBar extends StatelessWidget {
  final IngenieurNavController controller = Get.put(IngenieurNavController());
  
  // Couleur principale de l'application
  static const Color mainColor = Colors.deepPurple;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => controller.pages[controller.selectedIndex.value]), // Affiche la page active
      bottomNavigationBar: Obx(() => BottomNavigationBar(
        currentIndex: controller.selectedIndex.value,
        onTap: controller.changeTabIndex,
        selectedItemColor: mainColor,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Accueil"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Paramètres"),
        ],
      )),
    );
  }
}
