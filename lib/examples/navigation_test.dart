import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../views/qualiticiens/qualiticien_template_list_screen.dart';

/// Exemple de test de navigation vers la page des templates
/// Usage : await testNavigationToTemplates(activiteId: 123, activiteTitre: "Test Activité");
Future<void> testNavigationToTemplates({
  required int activiteId,
  required String activiteTitre,
}) async {
  // Navigation vers la page des templates avec les arguments
  Get.to(
    () => QualiticiensTemplateListScreen(),
    arguments: {
      'activiteSpecifiqueId': activiteId,
      'activiteSpecifiqueTitre': activiteTitre,
    },
  );
}

/// Widget d'exemple pour tester la navigation
class NavigationTestWidget extends StatelessWidget {
  const NavigationTestWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Navigation'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                testNavigationToTemplates(
                  activiteId: 1,
                  activiteTitre: "Activité Test 1",
                );
              },
              child: const Text('Tester Navigation Templates'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Ce bouton teste la navigation\nvers la page des templates',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
