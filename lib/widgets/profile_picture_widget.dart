import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/core/profile_picture_service.dart';

class ProfilePictureWidget extends StatelessWidget {
  final double size;
  final Color? borderColor;
  final double borderWidth;
  final bool showEditIcon;
  final Color? backgroundColor;

  const ProfilePictureWidget({
    super.key,
    this.size = 120,
    this.borderColor,
    this.borderWidth = 3,
    this.showEditIcon = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final ProfilePictureService profileService = Get.find<ProfilePictureService>();
    final color = borderColor ?? Colors.deepPurple;
    
    return Obx(() => Stack(
      children: [
        // Avatar principal
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: color,
              width: borderWidth,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipOval(
            child: _buildAvatarContent(profileService),
          ),
        ),
        
        // Icône d'édition
        if (showEditIcon)
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: profileService.showImageSourceDialog,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        
        // Indicateur de chargement
        if (profileService.isUploading.value)
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withOpacity(0.5),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    value: profileService.uploadProgress.value,
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(profileService.uploadProgress.value * 100).toInt()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    ));
  }

  Widget _buildAvatarContent(ProfilePictureService profileService) {
    if (profileService.hasSelectedImage) {
      return Image.file(
        File(profileService.selectedImagePath!),
        fit: BoxFit.cover,
        width: size,
        height: size,
      );
    }
    
    // Avatar par défaut
    return Container(
      color: backgroundColor ?? Colors.grey[200],
      child: Icon(
        Icons.person,
        size: size * 0.6,
        color: Colors.grey[400],
      ),
    );
  }
}

// Widget pour afficher uniquement le bouton de sélection d'image
class ProfilePictureButton extends StatelessWidget {
  final String? text;
  final IconData? icon;
  final Color? color;

  const ProfilePictureButton({
    super.key,
    this.text,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final ProfilePictureService profileService = Get.find<ProfilePictureService>();
    final buttonColor = color ?? Colors.deepPurple;
    
    return Obx(() => ElevatedButton.icon(
      onPressed: profileService.isUploading.value 
        ? null 
        : profileService.showImageSourceDialog,
      icon: profileService.isUploading.value
        ? SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
        : Icon(icon ?? Icons.camera_alt),
      label: Text(
        profileService.isUploading.value
          ? 'Upload en cours...'
          : (text ?? 'Changer la photo'),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ));
  }
}

// Widget d'aperçu de l'image sélectionnée
class ProfilePicturePreview extends StatelessWidget {
  final double width;
  final double height;
  final bool showClearButton;

  const ProfilePicturePreview({
    super.key,
    this.width = 200,
    this.height = 200,
    this.showClearButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final ProfilePictureService profileService = Get.find<ProfilePictureService>();
    
    return Obx(() {
      if (!profileService.hasSelectedImage) {
        return const SizedBox.shrink();
      }
      
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        child: Stack(
          children: [
            Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  File(profileService.selectedImagePath!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            
            if (showClearButton)
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: profileService.clearSelectedImage,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
}
