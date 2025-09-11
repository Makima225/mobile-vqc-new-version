import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_vqc_new_version/controllers/ingenieurs_travaux/ingenieur_travaux_fiche_remplis_detail_controller.dart';
import 'package:mobile_vqc_new_version/models/core/anomalie_model.dart';

class IngenieurTravauxFicheRemplisDetailScreen extends StatelessWidget {
  final IngenieurTravauxFicheRemplisDetailController _controller = Get.put(IngenieurTravauxFicheRemplisDetailController());

  static const Color mainColor = Colors.deepPurple;
  static const double portraitImageHeight = 500; // en pixels
  static const double portraitImageWidth = 350; // en pixels

  IngenieurTravauxFicheRemplisDetailScreen({super.key, required int ficheId}) {
    _controller.fetchFicheRemplieDetailById(ficheId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainColor,
        title: Center(
          child: Text(
            'Détail Fiche Remplie',
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
                // Affichage du nom et prénom du qualiticient
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Fiche remplie par : ",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            "${_controller.ficheRemplie['qualiticient_details']?['name'] ?? 'Nom inconnu'} ${_controller.ficheRemplie['qualiticient_details']?['surname'] ?? 'Prénom inconnu'}",
                            style: TextStyle(
                              fontSize: 16,
                              color: mainColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Container pour signature et photo du contrôle avec scroll horizontal
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // Conteneur pour la signature du qualiticient
                        Container(
                          margin: EdgeInsets.only(right: 16),
                          child: GestureDetector(
                            onTap: () {
                              final signatureUrl = _controller.ficheRemplie['signature_qualiticient'] ?? "";
                              if (signatureUrl.isNotEmpty) {
                                showDialog(
                                  context: context,
                                  builder: (context) => Dialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Container(
                                      constraints: BoxConstraints(
                                        maxHeight: MediaQuery.of(context).size.height * 0.8,
                                        maxWidth: MediaQuery.of(context).size.width * 0.9,
                                      ),
                                      padding: EdgeInsets.all(16),
                                      color: Colors.white,
                                      child: SingleChildScrollView(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              "Signature du qualiticient",
                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                            ),
                                            SizedBox(height: 16),
                                            Container(
                                              constraints: BoxConstraints(
                                                maxHeight: MediaQuery.of(context).size.height * 0.6,
                                              ),
                                              child: Image.network(
                                                signatureUrl,
                                                fit: BoxFit.contain,
                                                errorBuilder: (context, error, stackTrace) {
                                                  return Center(child: Text("Image non disponible"));
                                                },
                                              ),
                                            ),
                                            SizedBox(height: 16),
                                            ElevatedButton(
                                              onPressed: () => Navigator.pop(context),
                                              child: Text("Fermer"),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: mainColor,
                                                foregroundColor: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Image.network(
                                _controller.ficheRemplie['signature_qualiticient'] ?? "",
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(child: Text("Signature\nnon disponible", textAlign: TextAlign.center));
                                },
                              ),
                            ),
                          ),
                        ),
                        // Conteneur pour la photo du contrôle
                        Container(
                          child: GestureDetector(
                            onTap: () {
                              final photoUrl = _controller.ficheRemplie['photo'] ?? "";
                              if (photoUrl.isNotEmpty) {
                                showDialog(
                                  context: context,
                                  builder: (context) => Dialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Container(
                                      constraints: BoxConstraints(
                                        maxHeight: MediaQuery.of(context).size.height * 0.8,
                                        maxWidth: MediaQuery.of(context).size.width * 0.9,
                                      ),
                                      padding: EdgeInsets.all(16),
                                      color: Colors.white,
                                      child: SingleChildScrollView(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              "Photo du contrôle",
                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                            ),
                                            SizedBox(height: 16),
                                            Container(
                                              constraints: BoxConstraints(
                                                maxHeight: MediaQuery.of(context).size.height * 0.6,
                                              ),
                                              child: Image.network(
                                                photoUrl,
                                                fit: BoxFit.contain,
                                                errorBuilder: (context, error, stackTrace) {
                                                  return Center(child: Text("Image non disponible"));
                                                },
                                              ),
                                            ),
                                            SizedBox(height: 16),
                                            ElevatedButton(
                                              onPressed: () => Navigator.pop(context),
                                              child: Text("Fermer"),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: mainColor,
                                                foregroundColor: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Image.network(
                                _controller.ficheRemplie['photo'] ?? "",
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(child: Text("Photo\nnon disponible", textAlign: TextAlign.center));
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Boutons d'action
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Obx(() {
                          // Utiliser directement la liste d'anomalies du controller
                          final anomalies = _controller.anomalies;
                          final hasAnomalies = anomalies.isNotEmpty;
                          
                          print('🔍 Debug anomalies: ${anomalies.length} anomalies trouvées');
                          for (var anomalie in anomalies) {
                            print('  - Anomalie ID: ${anomalie.id}, Description: ${anomalie.description}');
                          }
                          
                          return ElevatedButton(
                            onPressed: hasAnomalies ? () {
                              _showAnomaliesDialog(context, anomalies);
                            } : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: hasAnomalies ? Colors.red : Colors.grey,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              hasAnomalies ? "Voir l'anomalie (${anomalies.length})" : "Aucune anomalie",
                              style: TextStyle(fontSize: 16),
                            ),
                          );
                        }),
                      ElevatedButton(
                        onPressed: () {
                          // Action pour signer
                          // Tu peux ajouter la logique de signature ici
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: mainColor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          "Signer",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
          
        }
      }),
    );
  }

  // Méthode pour afficher les anomalies dans une boîte de dialogue
  void _showAnomaliesDialog(BuildContext context, List<Anomalie> anomalies) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
              maxWidth: MediaQuery.of(context).size.width * 0.9,
            ),
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titre avec bouton de fermeture
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Détails des anomalies (${anomalies.length})",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                Divider(),
                // Contenu des anomalies avec défilement
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: anomalies.map((anomalie) {
                        return Card(
                          elevation: 3,
                          margin: EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Description :",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  anomalie.description,
                                  style: TextStyle(fontSize: 14),
                                ),
                                SizedBox(height: 10),
                                if (anomalie.dateSignalement != null) ...[
                                  Text(
                                    "Date de signalement :",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    "${anomalie.dateSignalement!.day}/${anomalie.dateSignalement!.month}/${anomalie.dateSignalement!.year} à ${anomalie.dateSignalement!.hour}:${anomalie.dateSignalement!.minute.toString().padLeft(2, '0')}",
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  SizedBox(height: 10),
                                ],
                                if (anomalie.photoUrl != null && anomalie.photoUrl!.isNotEmpty) ...[
                                  Text(
                                    "Photo de l'anomalie :",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          final orientation = MediaQuery.of(context).orientation;
                                          final screenHeight = MediaQuery.of(context).size.height;
                                          final screenWidth = MediaQuery.of(context).size.width;
                                          double maxHeight = orientation == Orientation.portrait
                                              ? screenHeight * 0.9
                                              : screenHeight * 0.7;
                                          double maxWidth = orientation == Orientation.portrait
                                              ? screenWidth * 0.95
                                              : screenWidth * 0.8;
                                          return Dialog(
                                            child: Container(
                                              constraints: BoxConstraints(
                                                maxHeight: maxHeight,
                                                maxWidth: maxWidth,
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  AppBar(
                                                    title: Text("Photo de l'anomalie"),
                                                    leading: IconButton(
                                                      icon: Icon(Icons.close),
                                                      onPressed: () => Navigator.pop(context),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Image.network(
                                                      anomalie.photoUrl!,
                                                      fit: BoxFit.contain,
                                                      errorBuilder: (context, error, stackTrace) {
                                                        return Center(child: Text("Image non disponible"));
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    child: Container(
                                      height: 400,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Image.network(
                                        anomalie.photoUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Center(child: Text("Image non disponible"));
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                // Bouton de fermeture en bas
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Center(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: IngenieurTravauxFicheRemplisDetailScreen.mainColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text("Fermer", style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}