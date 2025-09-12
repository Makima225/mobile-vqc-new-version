import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:signature/signature.dart';

class SignatureManager extends GetxController {
  final SignatureController signatureController = SignatureController(); // Utilisation correcte
  Rx<Uint8List?> signatureImage = Rx<Uint8List?>(null);

  // Effacer la signature
  void clearSignature() {
    signatureController.clear(); // ✅ Fonction bien définie dans la librairie
    signatureImage.value = null;
  }

  // Sauvegarder la signature
  Future<void> saveSignature() async {
    final Uint8List? image = await signatureController.toPngBytes(); // ✅ Fonction existante dans la librairie
    if (image != null) {
      signatureImage.value = image;
    }
  }

   // Récupérer la signature
  Uint8List? getSignature() {
    return signatureImage.value;
  }
}