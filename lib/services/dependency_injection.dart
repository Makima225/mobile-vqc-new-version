import 'package:get/get.dart';
import 'auth/auth_service.dart';
import 'core/sous_projets_service.dart';
import 'core/profile_picture_service.dart';
import 'core/activite_generale_service.dart';
import 'core/activite_specifique_by_activite_generale_service.dart';
import 'core/template_by_activite_specifique_service.dart';
import 'core/entete_by_template_service.dart';
import 'core/anomalie_service.dart';
import 'core/fiche_controle_service.dart';

class DependencyInjection {
  static Future<void> init() async {
    // Enregistrement de l'AuthService
    final authService = AuthService();
    await authService.init(); // Initialisation du service
    Get.put<AuthService>(authService);
    
    // Enregistrement du SousProjetService
    Get.put<SousProjetService>(SousProjetService());
    
    // Enregistrement du ProfilePictureService
    Get.put<ProfilePictureService>(ProfilePictureService());
    
    // Enregistrement de l'ActiviteGeneraleService
    Get.put<ActiviteGeneraleService>(ActiviteGeneraleService());
    
    // Enregistrement de l'ActiviteSpecifiqueByActiviteGeneraleService
    Get.put<ActiviteSpecifiqueByActiviteGeneraleService>(ActiviteSpecifiqueByActiviteGeneraleService());
    
    // Enregistrement du TemplateFichecontroleByActiviteSpecifiqueService
    Get.put<TemplateFichecontroleByActiviteSpecifiqueService>(TemplateFichecontroleByActiviteSpecifiqueService());
    
    // Enregistrement du EnteteByTemplateService
    Get.put<EnteteByTemplateService>(EnteteByTemplateService());
    
    // Enregistrement du AnomalieService
    Get.put<AnomalieService>(AnomalieService());
    
    // Enregistrement du FicheControleService
    Get.put<FicheControleService>(FicheControleService());
    
    print('Services d\'injection de dépendances initialisés');
  }
}
