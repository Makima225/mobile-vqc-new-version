import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:mobile_vqc_new_version/views/qualiticiens/qualiticien_home_screen.dart';
import 'package:mobile_vqc_new_version/views/qualiticiens/qualiticien_settings_screen.dart';


class QualiticienNavController extends GetxController {
  var selectedIndex = 0.obs;

  final List<Widget> pages = [
    QualiticiensousProjetList(),
    //QualiticianListAnomalie(),
   QualiticianSettings()
  ];

  void changeTabIndex(int index) {
    selectedIndex.value = index;
  }
}