import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_vqc_new_version/controllers/ingenieurs_travaux/ingenieur_template_by_activite_specifique_controller.dart';

class IngenieurTemplateByActiviteSpecifiqueScreen extends StatelessWidget {
  final int activiteSpecifiqueId;
  final IngenieurTemplateByActiviteSpecifiqueController _controller = Get.put(IngenieurTemplateByActiviteSpecifiqueController());

  static const Color mainColor = Colors.deepPurple;

  IngenieurTemplateByActiviteSpecifiqueScreen({super.key, required this.activiteSpecifiqueId});

  @override
  Widget build(BuildContext context) {
    // Charger les templates dès l'affichage de la page
    _controller.fetchTemplatesByActiviteSpecifique(activiteSpecifiqueId);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainColor,
        title: Center(
          child: Text(
            "Templates par Activité Spécifique",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        } else if (_controller.errorMessage.isNotEmpty) {
          return Center(child: Text(_controller.errorMessage.value));
        } else if (_controller.activitesSpecifiques.isEmpty) {
          return Center(child: Text("Aucun template trouvé pour cette activité spécifique."));
        } else {
          return ListView.builder(
            itemCount: _controller.activitesSpecifiques.length,
            itemBuilder: (context, index) {
              final template = _controller.activitesSpecifiques[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.all(10),
                  title: Text(
                    template['nom'] ?? 'Titre non disponible',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
                  onTap: () {
                    // Action à définir pour ouvrir le détail du template ou autre
                  },
                ),
              );
            },
          );
        }
      }),
    );
  }
}
