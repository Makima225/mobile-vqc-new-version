import 'package:get/get.dart';
import '../views/qualiticiens/qualiticien_template_list_screen.dart';

/// Exemple de navigation vers la page des templates
/// 
/// Cette classe montre comment naviguer vers la page de liste des templates
/// depuis d'autres parties de l'application.

class TemplateNavigationExample {
  
  /// Navigation depuis une page d'activité spécifique
  static void navigateFromActiviteSpecifique({
    required int activiteSpecifiqueId,
    required String activiteSpecifiqueTitre,
  }) {
    Get.to(
      () => QualiticiensTemplateListScreen(),
      arguments: {
        'activiteSpecifiqueId': activiteSpecifiqueId,
        'activiteSpecifiqueTitre': activiteSpecifiqueTitre,
      },
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 300),
    );
  }

  /// Navigation simple vers la page des templates
  static void navigateToTemplates() {
    Get.to(
      () => QualiticiensTemplateListScreen(),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 300),
    );
  }

  /// Navigation avec remplacement de la page actuelle
  static void replaceWithTemplates({
    int? activiteSpecifiqueId,
    String? activiteSpecifiqueTitre,
  }) {
    Get.off(
      () => QualiticiensTemplateListScreen(),
      arguments: activiteSpecifiqueId != null ? {
        'activiteSpecifiqueId': activiteSpecifiqueId,
        'activiteSpecifiqueTitre': activiteSpecifiqueTitre ?? '',
      } : null,
      transition: Transition.rightToLeft,
    );
  }

  /// Navigation avec suppression de toutes les pages précédentes
  static void navigateAndClearStack({
    int? activiteSpecifiqueId,
    String? activiteSpecifiqueTitre,
  }) {
    Get.offAll(
      () => QualiticiensTemplateListScreen(),
      arguments: activiteSpecifiqueId != null ? {
        'activiteSpecifiqueId': activiteSpecifiqueId,
        'activiteSpecifiqueTitre': activiteSpecifiqueTitre ?? '',
      } : null,
    );
  }
}
