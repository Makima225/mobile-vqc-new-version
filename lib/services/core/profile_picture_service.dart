import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/config.dart';
import '../auth/auth_service.dart';

class ProfilePictureService extends GetConnect {
  static ProfilePictureService get to => Get.find<ProfilePictureService>();
  
  final AuthService _authService = Get.find<AuthService>();
  final ImagePicker _picker = ImagePicker();

  // Observable pour l'image sélectionnée
  var imageFile = Rx<File?>(null);
  var isUploading = false.obs;
  var uploadProgress = 0.0.obs;

  @override
  void onInit() {
    // Configuration du service HTTP avec l'URL de base
    httpClient.baseUrl = AppConfig.baseUrl;
    
    // Intercepteur pour ajouter automatiquement les headers d'authentification
    httpClient.addRequestModifier<dynamic>((request) async {
      final headers = _authService.getAuthHeaders();
      request.headers.addAll(headers);
      
      print("🚀 Upload requête vers: ${request.url}");
      print("📡 Headers: ${request.headers}");
      
      return request;
    });

    // Intercepteur pour gérer les réponses
    httpClient.addResponseModifier((request, response) {
      print("📥 Réponse upload ${response.statusCode} de: ${request.url}");
      
      if (response.statusCode == 401) {
        print("❌ Token expiré lors de l'upload");
        _authService.refreshToken();
      }
      
      return response;
    });
    
    super.onInit();
  }

  // Fonction pour prendre une photo avec l'appareil photo
  Future<void> takePhoto() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        imageFile.value = File(pickedFile.path);
        
        Get.snackbar(
          'Photo prise',
          'Photo capturée avec succès',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          icon: const Icon(Icons.camera_alt, color: Colors.white),
        );
        
        // Upload automatique après capture
        await uploadProfilePicture();
      }
    } catch (e) {
      print("❌ Erreur lors de la prise de photo: $e");
      Get.snackbar(
        'Erreur',
        'Impossible d\'accéder à l\'appareil photo',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Fonction pour sélectionner une photo depuis la galerie
  Future<void> pickFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        imageFile.value = File(pickedFile.path);
        
        Get.snackbar(
          'Photo sélectionnée',
          'Image sélectionnée depuis la galerie',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.blue,
          colorText: Colors.white,
          icon: const Icon(Icons.photo_library, color: Colors.white),
        );
        
        // Upload automatique après sélection
        await uploadProfilePicture();
      }
    } catch (e) {
      print("❌ Erreur lors de la sélection de photo: $e");
      Get.snackbar(
        'Erreur',
        'Impossible d\'accéder à la galerie',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Afficher un sélecteur de source d'image
  Future<void> showImageSourceDialog() async {
    Get.defaultDialog(
      title: 'Photo de profil',
      titleStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
      content: Column(
        children: [
          const Text(
            'Choisissez la source de votre photo',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Bouton Appareil photo
              Column(
                children: [
                  IconButton(
                    onPressed: () {
                      Get.back();
                      takePhoto();
                    },
                    icon: const Icon(
                      Icons.camera_alt,
                      size: 32,
                      color: Colors.deepPurple,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.deepPurple.withOpacity(0.1),
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Appareil photo',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
              
              // Bouton Galerie
              Column(
                children: [
                  IconButton(
                    onPressed: () {
                      Get.back();
                      pickFromGallery();
                    },
                    icon: const Icon(
                      Icons.photo_library,
                      size: 32,
                      color: Colors.deepPurple,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.deepPurple.withOpacity(0.1),
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Galerie',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Annuler'),
        ),
      ],
    );
  }

  // Fonction pour uploader la photo vers l'API
  Future<bool> uploadProfilePicture() async {
    if (imageFile.value == null) {
      Get.snackbar(
        'Erreur',
        'Aucune image sélectionnée',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    try {
      isUploading.value = true;
      uploadProgress.value = 0.0;
      
      print("🔄 Début de l'upload de la photo de profil...");

      // Préparation du FormData
      final form = FormData({
        'picture': MultipartFile(
          imageFile.value!,
          filename: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      });

      // Appel API avec progress tracking
      final response = await post(
        "/update-picture/",
        form,
        uploadProgress: (percent) {
          uploadProgress.value = percent / 100;
          print("📤 Upload progress: ${percent.toStringAsFixed(1)}%");
        },
      );

      print("📩 Réponse upload photo: ${response.statusCode}");
      print("📄 Body: ${response.body}");

      if (response.statusCode == 200) {
        Get.snackbar(
          'Succès',
          'Photo de profil mise à jour avec succès',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle, color: Colors.white),
        );
        
        print("✅ Photo de profil uploadée avec succès");
        return true;
      } else {
        _handleUploadError(response);
        return false;
      }
    } catch (e) {
      print("❌ Exception lors de l'upload: $e");
      Get.snackbar(
        'Erreur',
        'Erreur réseau lors de l\'upload',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isUploading.value = false;
      uploadProgress.value = 0.0;
    }
  }

  // Gestion des erreurs d'upload
  void _handleUploadError(Response response) {
    String errorMessage;
    
    switch (response.statusCode) {
      case 400:
        errorMessage = 'Format d\'image non valide';
        break;
      case 401:
        errorMessage = 'Session expirée, veuillez vous reconnecter';
        break;
      case 413:
        errorMessage = 'Image trop volumineuse';
        break;
      case 415:
        errorMessage = 'Type de fichier non supporté';
        break;
      case 500:
        errorMessage = 'Erreur serveur';
        break;
      default:
        errorMessage = 'Échec de la mise à jour (${response.statusCode})';
    }
    
    print("❌ Erreur upload ${response.statusCode}: $errorMessage");
    
    Get.snackbar(
      'Erreur',
      errorMessage,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  // Supprimer l'image sélectionnée
  void clearSelectedImage() {
    imageFile.value = null;
    print("🗑️ Image sélectionnée supprimée");
  }

  // Vérifier si une image est sélectionnée
  bool get hasSelectedImage => imageFile.value != null;

  // Obtenir le chemin de l'image sélectionnée
  String? get selectedImagePath => imageFile.value?.path;

  // Vérifier si un upload est en cours
  bool get isUploadInProgress => isUploading.value;

  // Obtenir le pourcentage de progression
  double get progressPercentage => uploadProgress.value;
}
