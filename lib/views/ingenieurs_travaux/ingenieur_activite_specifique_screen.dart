import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_vqc_new_version/controllers/ingenieurs_travaux/ingenieur_activite_specifique_page_controller.dart';




class IngenieurActiviteSpecifiquesPage extends StatelessWidget {
  final int activiteGeneraleId;
  final IngenieurActiviteSpecifiquesPageController _controller = Get.put(IngenieurActiviteSpecifiquesPageController());

  static const Color mainColor = Colors.deepPurple;
  
  IngenieurActiviteSpecifiquesPage({super.key, required this.activiteGeneraleId});

  @override
  Widget build(BuildContext context) {
    // Charger les activités spécifiques dès l'affichage de la page
    _controller.fetchActivitesSpecifiques(activiteGeneraleId);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainColor,
        title: Center(
          child: Text(
            "Activités Spécifiques",
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
          return Center(child: Text("Aucune activité spécifique trouvée."));
        } else {
          return ListView.builder(
            itemCount: _controller.activitesSpecifiques.length,
            itemBuilder: (context, index) {
              final activite = _controller.activitesSpecifiques[index];

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.all(10),
                  title: Text(
                    activite['titre'] ?? 'Titre non disponible',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
                  // onTap: () {
                  //  Get.to(IngenieurFichesRempliesPage(
                  //   activiteSpecifiqueId: activite['id'],
                  //   activiteTitre: activite['titre']));
                  // },
                ),
              );
            },
          );
        }
      }),
    );
  }
}