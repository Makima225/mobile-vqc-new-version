import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/qualiticiens/activite_general_controller.dart';
import '../../widgets/activite_generale_card.dart';
import '../../widgets/error_state_widget.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/loading_widget.dart';
import 'qualiticien_activite_specifique_screen.dart';

class QualiticiensActiviteGeneraleList extends StatelessWidget {
  final ActiviteGeneralController _controller = Get.put(ActiviteGeneralController());
  
  // Couleur principale de l'application
  static const Color mainColor = Colors.deepPurple;

  QualiticiensActiviteGeneraleList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // AppBar avec design moderne
          _buildSliverAppBar(),
          
          // Contenu principal
          SliverToBoxAdapter(
            child: Obx(() => _buildMainContent()),
          ),
        ],
      ),
      
      // Bouton flottant pour rafraîchir
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: mainColor,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Activités Générales',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                mainColor,
                mainColor.withOpacity(0.8),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                top: -20,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              Positioned(
                right: 30,
                top: 30,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        // Indicateur de chargement ou bouton refresh
        Obx(() => _controller.isLoading 
          ? const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            )
          : IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              onPressed: _controller.refreshActivitesGenerales,
            ),
        ),
      ],
    );
  }

  Widget _buildMainContent() {
    if (_controller.isLoading) {
      return const SizedBox(
        height: 400,
        child: LoadingWidget(
          message: 'Chargement des activités générales...',
          primaryColor: mainColor,
        ),
      );
    }
    
    if (_controller.hasError) {
      return SizedBox(
        height: 400,
        child: ErrorStateWidget(
          message: _controller.errorMessage,
          onRetry: _controller.retryLoading,
          retryText: 'Réessayer',
          primaryColor: mainColor,
        ),
      );
    }
    
    if (_controller.activitesGenerales.isEmpty) {
      return SizedBox(
        height: 400,
        child: EmptyStateWidget(
          title: 'Aucune activité générale trouvée',
          subtitle: 'Aucune activité n\'est assignée à votre compte qualiticien.',
          icon: Icons.assignment_outlined,
          onRefresh: _controller.refreshActivitesGenerales,
          refreshText: 'Actualiser',
          primaryColor: mainColor,
        ),
      );
    }
    
    return Column(
      children: [
        // Message de rafraîchissement
        _buildRefreshHint(),
        
       
        
        // Liste des activités générales
        _buildActivitesList(),
      ],
    );
  }

  Widget _buildRefreshHint() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.withOpacity(0.1),
            Colors.green.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.green.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.swipe_down_rounded,
            color: Colors.green[700],
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Faites glisser vers le bas pour actualiser',
              style: TextStyle(
                color: Colors.green[700],
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildActivitesList() {
    return RefreshIndicator(
      onRefresh: _controller.refreshActivitesGenerales,
      color: mainColor,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _controller.activitesGenerales.length,
        itemBuilder: (context, index) {
          final activite = _controller.activitesGenerales[index];
          
          return ActiviteGeneraleCard(
            activite: activite,
            isSelected: false, // Pas de sélection pour les activités
            primaryColor: mainColor,
            onTap: () {
              // Navigation vers la page des activités spécifiques liées à cette activité générale
              Get.to(
                () => QualiticiensActiviteSpecifiqueList(),
                arguments: {
                  'activiteGeneraleId': activite.id,
                  'activiteGeneraleTitre': activite.titre,
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () => _controller.refreshActivitesGenerales(),
      backgroundColor: mainColor,
      foregroundColor: Colors.white,
      tooltip: 'Rafraîchir la liste',
      child: const Icon(Icons.refresh),
    );
  }
}