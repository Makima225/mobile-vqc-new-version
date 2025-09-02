import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/auth/auth_service.dart';
import 'ingenieur_travaux_nav_bar.dart';
import 'qualiticien_nav_bar.dart';

class BottomNavSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final AuthService authService = Get.find<AuthService>();
      String? role = authService.userRole.value;

      if (role == null) {
        return Center(child: CircularProgressIndicator());
      }

      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text("Bienvenue, $role")), // Contenu principal
        bottomNavigationBar: role == "ingenieur travaux"
            ? IngenieurNavBar()
            : QualiticienNavBar(),
      );
    });
  }
}
