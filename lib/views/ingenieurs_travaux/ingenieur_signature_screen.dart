import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:mobile_vqc_new_version/controllers/ingenieurs_travaux/ingenieur_signature_page_controller.dart';
import 'package:get/get.dart';
import 'package:signature/signature.dart';

class SignaturePage extends StatelessWidget {
  final SignatureManager controller = Get.put(SignatureManager());

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Calculer la hauteur de la signature selon l'orientation
    final appBarHeight = kToolbarHeight;
    final availableHeight = screenHeight - appBarHeight - MediaQuery.of(context).padding.top;
    final signatureHeight = orientation == Orientation.portrait
        ? availableHeight * 0.65  // 65% en portrait
        : availableHeight * 0.5;  // 50% en paysage
    
    return Scaffold(
      appBar: AppBar(
        title: Text("Signature"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Zone de signature avec hauteur adaptative
            Container(
              height: signatureHeight,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[400]!),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: Signature(
                controller: controller.signatureController,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            // Boutons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: controller.clearSignature,
                    child: Text("Effacer", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () async {
                      // Sauvegarder localement sans envoyer au backend
                      await controller.saveSignature();
                      
                      if (controller.signatureImage.value != null) {
                        // Retourner la signature à la page précédente
                        Get.back(result: controller.signatureImage.value);
                        
                        // Afficher un message de confirmation
                        Get.snackbar(
                          "Signature enregistrée",
                          "La signature a été sauvegardée localement",
                          backgroundColor: Colors.green[100],
                          colorText: Colors.green[800],
                          icon: Icon(Icons.check_circle, color: Colors.green),
                          duration: Duration(seconds: 2),
                        );
                      } else {
                        // Aucune signature dessinée
                        Get.snackbar(
                          "Aucune signature",
                          "Veuillez dessiner une signature avant d'enregistrer",
                          backgroundColor: Colors.orange[100],
                          colorText: Colors.orange[800],
                          icon: Icon(Icons.warning, color: Colors.orange),
                        );
                      }
                    },
                    child: Text("Enregistrer", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Affichage de la signature enregistrée (optionnel)
            Obx(() {
              Uint8List? signature = controller.signatureImage.value;
              return signature != null
                  ? Container(
                      margin: EdgeInsets.only(top: 16),
                      child: Column(
                        children: [
                          Text(
                            "Aperçu de la signature :",
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          SizedBox(height: 8),
                          Container(
                            height: 80,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Image.memory(
                              signature,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                    )
                  : SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
    
  }
}