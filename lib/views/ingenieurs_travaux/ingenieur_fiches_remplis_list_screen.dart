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
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async {
              await _controller.fetchFichesRempliesListByTemplate(templateId, showOverlay: false);
            },
            child: Obx(() {
              if (_controller.isLoading.value) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(height: 200),
                    Center(child: CircularProgressIndicator()),
                  ],
                );
              } else if (_controller.errorMessage.isNotEmpty) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(height: 200),
                    Center(child: Text(_controller.errorMessage.value)),
                  ],
                );
              } else if (_controller.fichesRemplies.isEmpty) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(height: 200),
                    Center(child: Text("Aucune fiche remplie trouvée pour ce template.")),
                  ],
                );
              } else {
                // Filtrer les fiches avec etat_de_la_fiche == 'Remplis'
                final fichesRempliesFiltrees = _controller.fichesRemplies.where((fiche) => fiche['etat_de_la_fiche'] == 'Remplis').toList();
                if (fichesRempliesFiltrees.isEmpty) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(height: 200),
                      Center(child: Text("Aucune fiche 'Remplis' trouvée pour ce template.")),
                    ],
                  );
                }
                return ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: fichesRempliesFiltrees.length,
                  itemBuilder: (context, index) {
                    final fiche = fichesRempliesFiltrees[index];
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
                            Text("État : "+(fiche['etat_de_la_fiche'] ?? 'Non défini')),
                            Text("Créé le : "+(fiche['created_at'] != null ? fiche['created_at'].toString().substring(0, 19).replaceAll('T', ' ') : 'Date inconnue')),
                          ],
                        ),
                        trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
                        onTap: () async {
                          final int ficheId = fiche['id'];
                          // Naviguer vers la page de détail et attendre le résultat
                          final result = await Get.to(() => IngenieurTravauxFicheRemplisDetailScreen(ficheId: ficheId));
                          // Si la fiche a été validée, rafraîchir la liste avec overlay
                          if (result == 'validated') {
                            print('🔄 Fiche validée, rafraîchissement de la liste...');
                            await _controller.fetchFichesRempliesListByTemplate(templateId, showOverlay: true);
                            // Afficher un message de confirmation
                            Get.snackbar(
                              "Liste mise à jour",
                              "La liste des fiches a été rafraîchie",
                              backgroundColor: Colors.blue[100],
                              colorText: Colors.blue[800],
                              icon: Icon(Icons.refresh, color: Colors.blue),
                              duration: Duration(seconds: 2),
                            );
                          }
                        },
                      ),
                    );
                  },
                );
              }
            }),
          ),
          // Overlay loader pendant le rafraîchissement
          Obx(() {
            if (_controller.isRefreshing.value) {
              return Container(
                color: Colors.black.withOpacity(0.2),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Colors.deepPurple),
                      SizedBox(height: 16),
                      Text('Mise à jour de la liste...', style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              );
            } else {
              return SizedBox.shrink();
            }
          }),
        ],
      ),
    );
  }
}