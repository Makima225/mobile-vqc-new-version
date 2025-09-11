import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_vqc_new_version/controllers/ingenieurs_travaux/ingenieur_travaux_fiche_remplis_detail_controller.dart';



class IngenieurTravauxFicheRemplisDetailScreen extends StatelessWidget {
  final IngenieurTravauxFicheRemplisDetailController _controller = Get.put(IngenieurTravauxFicheRemplisDetailController());

  static const Color mainColor = Colors.deepPurple;

  IngenieurTravauxFicheRemplisDetailScreen({super.key, required int ficheId}) {
    _controller.fetchFicheRemplieDetailById(ficheId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainColor,
        title: Center(
          child:  Text('Détail Fiche Remplie', 
          style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
          ),

        )
        
      ),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        } else if (_controller.errorMessage.isNotEmpty) {
          return Center(child: Text(_controller.errorMessage.value));
        } else {
          return SingleChildScrollView(
            child: Column(
              children: [
                Card(
                  margin: EdgeInsets.all(16),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Informations des entêtes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        SizedBox(height: 12),
                        ...(_controller.ficheRemplie['entete_values'] as List<dynamic>? ?? []).map((entete) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(entete["entete_titre"] ?? "Titre inconnu", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              SizedBox(height: 4),
                              Text(entete["valeur"] ?? "Valeur non disponible", style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                              Divider(),
                            ],
                          ),
                        )).toList(),
                      ],
                    ),
                  ),
                ),
                // Tableau scrollable
                Card(
                  margin: EdgeInsets.all(16),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Données du contrôle', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        SizedBox(height: 12),
                        Builder(
                          builder: (context) {
                            final tables = _controller.ficheRemplie['donnees']?['tables'] as List<dynamic>? ?? [];
                            final table = tables.isNotEmpty ? tables[0] : null;
                            if (table == null) {
                              return Text('Aucun tableau disponible');
                            }
                            return SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                columns: (table['headers'] as List<dynamic>)
                                    .map<DataColumn>((header) => DataColumn(label: Text(header.toString())))
                                    .toList(),
                                rows: (table['rows'] as List<dynamic>)
                                    .map<DataRow>((row) => DataRow(
                                          cells: (row as List<dynamic>)
                                              .map<DataCell>((cell) => DataCell(Text(cell.toString())))
                                              .toList(),
                                        ))
                                    .toList(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
          
        }
      }),
    );
  }
}