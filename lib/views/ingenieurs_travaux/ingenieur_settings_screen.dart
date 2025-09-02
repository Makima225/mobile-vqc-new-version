import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/core/profile_picture_service.dart';
import '../../services/auth/auth_service.dart';
import '../../widgets/profile_picture_widget.dart';
import '../auth/change_password_screen.dart';

class IngenieurSettings extends StatefulWidget {
  const IngenieurSettings({super.key});

  @override
  State<IngenieurSettings> createState() => _IngenieurSettingsState();
}

class _IngenieurSettingsState extends State<IngenieurSettings> {
  final ProfilePictureService profileService = Get.find<ProfilePictureService>();
  final AuthService authService = Get.find<AuthService>();
  
  // Couleur principale (adaptez selon votre thème)
  static const Color mainColor = Colors.deepPurple;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainColor,
        title: const Padding(
          padding: EdgeInsets.symmetric(vertical: 30),
          child: Center(
            child: Text(
              "Paramètres",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),
            
            // Carte de profil utilisateur
            _buildUserProfileCard(),
            
            const SizedBox(height: 30),
            const Divider(),
            
            // Section des paramètres
            _buildSettingsSection(),
            
            const SizedBox(height: 30),
            
            // Logo Vinci
            _buildVinciLogo(),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfileCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: mainColor.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Photo de profil avec notre widget
          const ProfilePictureWidget(
            size: 100,
            borderColor: mainColor,
            borderWidth: 3,
            showEditIcon: true,
          ),
          
          const SizedBox(height: 16),
          
          // Informations utilisateur
          const Text(
            'John Smith', // Remplacez par les vraies données utilisateur
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          
          const SizedBox(height: 4),
          
          Text(
            'Ingénieur Travaux',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: mainColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'En ligne',
                  style: TextStyle(
                    color: mainColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // En-tête de section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: mainColor.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.engineering,
                  color: mainColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Actions Ingénieur',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: mainColor,
                  ),
                ),
              ],
            ),
          ),
          
          // Options des paramètres spécifiques aux ingénieurs
          _buildSettingsTile(
            icon: Icons.add_a_photo_outlined,
            title: "Ajouter une photo",
            subtitle: "Modifier votre photo de profil",
            onTap: () => profileService.showImageSourceDialog(),
            iconColor: Colors.blue,
          ),
          
          _buildDivider(),
          
          _buildSettingsTile(
            icon: Icons.assignment_outlined,
            title: "Mes projets",
            subtitle: "Consulter mes projets assignés",
            onTap: () {
              // TODO: Navigation vers la liste des projets
              Get.snackbar(
                'Navigation',
                'Ouverture de la liste des projets...',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            iconColor: Colors.green,
          ),
          
          _buildDivider(),
          
          _buildSettingsTile(
            icon: Icons.bar_chart_outlined,
            title: "Rapports",
            subtitle: "Générer et consulter les rapports",
            onTap: () {
              // TODO: Navigation vers les rapports
              Get.snackbar(
                'Navigation',
                'Ouverture des rapports...',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            iconColor: Colors.purple,
          ),
          
          _buildDivider(),
          
          _buildSettingsTile(
            icon: Icons.password_rounded,
            title: "Changer le mot de passe",
            subtitle: "Modifier votre mot de passe",
            onTap: () {
              Get.to(() => const ChangePasswordScreen());
            },
            iconColor: Colors.orange,
          ),
          
          _buildDivider(),
          
          _buildSettingsTile(
            icon: Icons.notifications_outlined,
            title: "Notifications",
            subtitle: "Gérer vos notifications",
            onTap: () {
              // TODO: Navigation vers les paramètres de notifications
              Get.snackbar(
                'Navigation',
                'Ouverture des paramètres de notifications...',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            iconColor: Colors.teal,
          ),
          
          _buildDivider(),
          
          _buildSettingsTile(
            icon: Icons.logout_outlined,
            title: "Déconnexion",
            subtitle: "Se déconnecter de l'application",
            onTap: _showLogoutDialog,
            iconColor: Colors.red,
            showArrow: false,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color iconColor,
    bool showArrow = true,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey[600],
        ),
      ),
      trailing: showArrow
          ? Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.grey[400],
            )
          : null,
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      indent: 60,
      endIndent: 20,
      color: Colors.grey[200],
    );
  }

  Widget _buildVinciLogo() {
    return Container(
      width: 200,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          "assets/images/VINCI.png",
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[100],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.business,
                    color: Colors.grey[400],
                    size: 40,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'VINCI',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    Get.defaultDialog(
      title: 'Déconnexion',
      titleStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
      content: Column(
        children: [
          Icon(
            Icons.logout_rounded,
            color: Colors.red,
            size: 48,
          ),
          const SizedBox(height: 16),
          const Text(
            'Êtes-vous sûr de vouloir vous déconnecter ?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text(
            'Annuler',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Get.back();
            authService.logout();
            Get.snackbar(
              'Déconnexion',
              'Vous avez été déconnecté avec succès',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green,
              colorText: Colors.white,
              icon: const Icon(Icons.check_circle, color: Colors.white),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: const Text('Se déconnecter'),
        ),
      ],
    );
  }
}
