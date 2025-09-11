import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_vqc_new_version/controllers/ingenieurs_travaux/ingenieur_fiche_remplis_list_controller.dart';
import 'package:mobile_vqc_new_version/views/ingenieurs_travaux/ingenieur_travaux_fiche_remplis_detail_screen.dart';

class IngenieurFichesRemplisListScreen extends StatelessWidget {
   
  final int templateId;
  final IngenieurFicheRemplisListController _controller = Get.put(IngenieurFicheRemplisListController());

  static const Color mainColor = Colors.deepPurple;

  IngenieurFichesRemplisListScreen({super.key, required this.templateId});

  @override
  Widget build(BuildContext context) {
    // Charger les fiches dès l'affichage de la page
    _controller.fetchFichesRempliesListByTemplate(templateId);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainColor,
        title: Center(
          child: Text(
            "Fiches Remplies",
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
        } else if (_controller.fichesRemplies.isEmpty) {
          return Center(child: Text("Aucune fiche remplie trouvée pour ce template."));
        } else {
          return ListView.builder(
            itemCount: _controller.fichesRemplies.length,
            itemBuilder: (context, index) {
              final fiche = _controller.fichesRemplies[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.all(10),
                  title: Text(
                    fiche['nom'] ?? 'Nom non disponible',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("État : ${fiche['etat_de_la_fiche'] ?? 'Non défini'}"),
                      Text("Créé le : ${fiche['created_at'] != null ? fiche['created_at'].toString().substring(0, 19).replaceAll('T', ' ') : 'Date inconnue'}"),
                    ],
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
                  onTap: () {
                    final int ficheId = fiche['id'];
                    Get.to(() => IngenieurTravauxFicheRemplisDetailScreen(ficheId: ficheId));
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