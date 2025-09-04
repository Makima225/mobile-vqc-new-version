import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/core/fiche_controle_controller.dart';
import '../../models/core/template_model.dart';

class SignatureScreen extends StatefulWidget {
  final TemplateFichecontrole template;
  final int activiteSpecifiqueId;
  final Map<String, String> enteteValues;
  final Map<String, dynamic> schemaData;
  final File? photoObligatoire; // Photo du bouton "Prendre une photo"
  final List<Map<String, dynamic>>? anomalies; // Anomalies optionnelles

  const SignatureScreen({
    super.key,
    required this.template,
    required this.activiteSpecifiqueId,
    required this.enteteValues,
    required this.schemaData,
    this.photoObligatoire,
    this.anomalies,
  });

  @override
  State<SignatureScreen> createState() => _SignatureScreenState();
}

class _SignatureScreenState extends State<SignatureScreen> {
  final GlobalKey<SignaturePainterState> _signatureKey = GlobalKey<SignaturePainterState>();
  final FicheControleController _ficheController = Get.put(FicheControleController());
  bool _isSignatureEmpty = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Signature du formulaire',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700], size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Veuillez signer dans la zone ci-dessous pour valider votre formulaire.',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Zone de signature
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[300]!, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Column(
                    children: [
                      // Header de la zone de signature
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          border: Border(
                            bottom: BorderSide(color: Colors.grey[200]!),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: Colors.grey[600], size: 20),
                            const SizedBox(width: 5),
                            Text(
                              'Zone de signature',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                            const Spacer(),
                            TextButton.icon(
                              onPressed: _clearSignature,
                              icon: const Icon(Icons.clear, size: 18),
                              label: const Text('Effacer'),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red[600],
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Canvas de signature
                      Expanded(
                        child: SignaturePainter(
                          key: _signatureKey,
                          onSignatureChanged: (isEmpty) {
                            setState(() {
                              _isSignatureEmpty = isEmpty;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Boutons d'action
            Row(
              children: [
                // Bouton Annuler
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.cancel_outlined),
                    label: const Text('Annuler'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[700],
                      side: BorderSide(color: Colors.grey[300]!),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Bouton Terminer
                Expanded(
                  flex: 2,
                  child: Obx(() => ElevatedButton.icon(
                    onPressed: (_isSignatureEmpty || _ficheController.isSubmitting.value) 
                        ? null 
                        : _finishForm,
                    icon: _ficheController.isSubmitting.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.check_circle_outline),
                    label: Text(
                      _ficheController.isSubmitting.value 
                          ? 'Envoi en cours...' 
                          : 'Terminer le formulaire',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: (_isSignatureEmpty || _ficheController.isSubmitting.value) 
                          ? Colors.grey[400] 
                          : Colors.green[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: (_isSignatureEmpty || _ficheController.isSubmitting.value) ? 0 : 3,
                    ),
                  )),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _clearSignature() {
    _signatureKey.currentState?.clear();
    setState(() {
      _isSignatureEmpty = true;
    });
  }

  Future<void> _finishForm() async {
    if (_isSignatureEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Veuillez signer avant de terminer'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Vérification de la photo obligatoire
      if (widget.photoObligatoire == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Une photo est obligatoire pour valider le formulaire'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
        return;
      }

      // Récupérer la signature comme image et la sauvegarder temporairement
      final Uint8List? signatureBytes = await _signatureKey.currentState?.toImage();
      
      if (signatureBytes == null) {
        throw Exception('Impossible de générer la signature');
      }

      // Créer un fichier temporaire pour la signature
      final tempDir = Directory.systemTemp;
      final signatureFile = File('${tempDir.path}/signature_${DateTime.now().millisecondsSinceEpoch}.png');
      await signatureFile.writeAsBytes(signatureBytes);

      print('📝 Démarrage de la soumission du formulaire...');
      print('📋 Template: ${widget.template.nom}');
      print('📷 Photo obligatoire: ${widget.photoObligatoire!.path}');
      print('✍️ Signature créée: ${signatureFile.path}');

      // Validation et soumission via le controller
      final success = await _ficheController.submitFormulaire(
        template: widget.template,
        activiteSpecifiqueId: widget.activiteSpecifiqueId,
        enteteValues: widget.enteteValues,
        schemaData: widget.schemaData,
        photoObligatoire: widget.photoObligatoire!,
        signatureFile: signatureFile,
        anomalies: widget.anomalies,
      );

      if (success) {
        // Nettoyer le fichier temporaire
        try {
          await signatureFile.delete();
        } catch (e) {
          print('⚠️ Impossible de supprimer le fichier temporaire: $e');
        }

        // Afficher une confirmation
        await Get.dialog(
          AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green[600], size: 28),
                const SizedBox(width: 12),
                const Text('Formulaire envoyé !'),
              ],
            ),
            content: const Text(
              'Votre fiche de contrôle a été créée et envoyée avec succès au serveur.',
              style: TextStyle(fontSize: 16),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Get.back(); // Fermer le dialog
                  Get.back(); // Retourner à l'écran de remplissage
                  Get.back(); // Retourner à la liste des templates
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Retour à la liste'),
              ),
            ],
          ),
          barrierDismissible: false,
        );
      }
      
    } catch (e) {
      print('❌ Erreur lors de la finalisation: $e');
      
      // Afficher l'erreur à l'utilisateur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Réessayer',
            textColor: Colors.white,
            onPressed: () => _finishForm(),
          ),
        ),
      );
    }
  }
}

// Widget personnalisé pour le canvas de signature
class SignaturePainter extends StatefulWidget {
  final Function(bool isEmpty) onSignatureChanged;

  const SignaturePainter({
    super.key,
    required this.onSignatureChanged,
  });

  @override
  State<SignaturePainter> createState() => SignaturePainterState();
}

class SignaturePainterState extends State<SignaturePainter> {
  final List<Offset?> _points = [];
  bool _isEmpty = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _points.add(details.localPosition);
            if (_isEmpty) {
              _isEmpty = false;
              widget.onSignatureChanged(false);
            }
          });
        },
        onPanEnd: (details) {
          _points.add(null); // Marquer la fin du trait
        },
        child: CustomPaint(
          painter: _SignatureCustomPainter(_points),
          size: Size.infinite,
        ),
      ),
    );
  }

  void clear() {
    setState(() {
      _points.clear();
      _isEmpty = true;
    });
    widget.onSignatureChanged(true);
  }

  Future<Uint8List?> toImage() async {
    if (_isEmpty) return null;
    
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = context.size ?? const Size(300, 200);
    
    // Dessiner un fond blanc
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.white,
    );
    
    // Dessiner la signature
    _SignatureCustomPainter(_points).paint(canvas, size);
    
    final picture = recorder.endRecording();
    final img = await picture.toImage(size.width.toInt(), size.height.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    
    return byteData?.buffer.asUint8List();
  }
}

// Painter personnalisé pour dessiner la signature
class _SignatureCustomPainter extends CustomPainter {
  final List<Offset?> points;

  _SignatureCustomPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
