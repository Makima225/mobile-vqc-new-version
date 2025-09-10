import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_vqc_new_version/controllers/ingenieurs_travaux/ingenieur_home_page_controller.dart';



class IngenieurHomeScreen extends StatelessWidget {
  final ActiviteGeneraleController _controller = Get.put(ActiviteGeneraleController());
 
  static const Color mainColor = Colors.deepPurple;

  IngenieurHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainColor,
        title: Padding(
          padding: EdgeInsets.symmetric(vertical: 30),
          child: Center(
            child: Text(
              "Accueil",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        } else if (_controller.errorMessage.isNotEmpty) {
          return Center(child: Text(_controller.errorMessage.value));
        } else if (_controller.activitesGenerales.isEmpty) {
          return Center(child: Text("Aucune activité générale trouvée."));
        } else {
          return ListView.builder(
            itemCount: _controller.activitesGenerales.length,
            itemBuilder: (context, index) {
              final activite = _controller.activitesGenerales[index];

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
                  //   final int activiteGeneraleId = activite['id'];
                  //   Get.to(() => IngenieurActiviteSpecifiquesPage(
                  //     activiteGeneraleId: activiteGeneraleId,
                  //   ));
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
