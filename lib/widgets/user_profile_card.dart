import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth/auth_service.dart';
import '../widgets/profile_picture_widget.dart';

class UserProfileCard extends StatelessWidget {
  final double? width;
  final EdgeInsetsGeometry? margin;
  final bool showStatus;
  final Color? primaryColor;

  const UserProfileCard({
    super.key,
    this.width,
    this.margin,
    this.showStatus = true,
    this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final AuthService authService = Get.find<AuthService>();
    final color = primaryColor ?? Colors.deepPurple;
    
    return Container(
      width: width,
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Photo de profil
          ProfilePictureWidget(
            size: 80,
            borderColor: color,
            borderWidth: 3,
            showEditIcon: false,
          ),
          
          const SizedBox(height: 16),
          
          // Nom d'utilisateur (vous pouvez récupérer depuis authService)
          Text(
            _getUserName(authService),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          
          const SizedBox(height: 4),
          
          // Rôle utilisateur
          Text(
            _getUserRole(authService),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          
          // Badge de statut
          if (showStatus) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'En ligne',
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getUserName(AuthService authService) {
    // Vous pouvez récupérer le nom depuis le token JWT ou les préférences
    // Pour l'instant, on retourne un nom par défaut
    return 'Utilisateur';
  }

  String _getUserRole(AuthService authService) {
    // Vous pouvez récupérer le rôle depuis le token JWT
    return authService.userRole.value ?? 'Qualiticien';
  }
}

// Widget compact pour afficher le profil dans une AppBar ou une liste
class CompactUserProfile extends StatelessWidget {
  final Color? textColor;
  final double avatarSize;
  final bool showName;

  const CompactUserProfile({
    super.key,
    this.textColor,
    this.avatarSize = 32,
    this.showName = true,
  });

  @override
  Widget build(BuildContext context) {
    final AuthService authService = Get.find<AuthService>();
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ProfilePictureWidget(
          size: avatarSize,
          borderColor: textColor ?? Colors.white,
          borderWidth: 2,
          showEditIcon: false,
        ),
        
        if (showName) ...[
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Bonjour,',
                style: TextStyle(
                  color: textColor ?? Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                authService.userRole.value ?? 'Utilisateur',
                style: TextStyle(
                  color: textColor ?? Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
