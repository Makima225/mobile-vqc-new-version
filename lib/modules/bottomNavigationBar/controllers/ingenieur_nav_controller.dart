import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:mobile_vqc_new_version/views/ingenieurs_travaux/ingenieur_home_screen.dart';
import 'package:mobile_vqc_new_version/views/ingenieurs_travaux/ingenieur_settings_screen.dart';


class IngenieurNavController extends GetxController {
  var selectedIndex = 0.obs;

  final List<Widget> pages = [
    IngenieurHomeScreen(),
    IngenieurSettingsScreen()
  ];

  void changeTabIndex(int index) {
    selectedIndex.value = index;
  }
}