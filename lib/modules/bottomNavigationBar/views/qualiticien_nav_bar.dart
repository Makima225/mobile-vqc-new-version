import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/qualiticien_nav_controller.dart';

class QualiticienNavBar extends StatelessWidget {
  final QualiticienNavController controller = Get.put(QualiticienNavController());
  
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
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Accueil"),
          // BottomNavigationBarItem(icon: Icon(Icons.report_problem), label: "Anomalies"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Paramètres"),
        ],
      )),
    );
  }
}
