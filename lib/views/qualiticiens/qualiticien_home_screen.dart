import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/qualiticiens/sous_projet_controller.dart';
import '../../widgets/sous_projet_card.dart';
import '../../widgets/error_state_widget.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/sous_projet_detail_card.dart';
import 'qualiticien_activite_generale_screen.dart';

class QualiticiensousProjetList extends StatelessWidget {
  final QualiticiansousProjetController _controller = Get.put(QualiticiansousProjetController());
  
  // Couleur principale de l'application
  static const Color mainColor = Colors.deepPurple;

  QualiticiensousProjetList({super.key});

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
          'Bienvenue ',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
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
        Obx(() => _controller.isLoading.value 
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
              onPressed: _controller.refreshSousProjets,
            ),
        ),
      ],
    );
  }

  Widget _buildMainContent() {
    if (_controller.isLoading.value) {
      return const SizedBox(
        height: 400,
        child: LoadingWidget(
          message: 'Chargement des sous-projets...',
          primaryColor: mainColor,
        ),
      );
    }
    
    if (_controller.errorMessage.isNotEmpty) {
      return SizedBox(
        height: 400,
        child: ErrorStateWidget(
          message: _controller.errorMessage.value,
          onRetry: _controller.refreshSousProjets,
          retryText: 'Réessayer',
          primaryColor: mainColor,
        ),
      );
    }
    
    if (_controller.sousProjets.isEmpty) {
      return SizedBox(
        height: 400,
        child: EmptyStateWidget(
          title: 'Aucun sous-projet trouvé',
          subtitle: 'Aucun sous-projet n\'est assigné à votre compte qualiticien.',
          icon: Icons.assignment_outlined,
          onRefresh: _controller.refreshSousProjets,
          refreshText: 'Actualiser',
          primaryColor: mainColor,
        ),
      );
    }
    
    return Column(
      children: [
        // Message de rafraîchissement
        _buildRefreshHint(),
        
        // Détails du sous-projet sélectionné
        if (_controller.hasSousProjetSelected())
          SousProjetDetailCard(
            sousProjet: _controller.selectedSousProjet.value!,
            details: _controller.sousProjetDetails.value,
            isLoading: _controller.isLoadingDetails.value,
            primaryColor: mainColor,
          ),
        
        // Liste des sous-projets
        _buildSousProjetsList(),
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

  Widget _buildSousProjetsList() {
    return RefreshIndicator(
      onRefresh: _controller.refreshSousProjets,
      color: mainColor,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _controller.sousProjets.length,
        itemBuilder: (context, index) {
          final sousProjet = _controller.sousProjets[index];
          final isSelected = _controller.selectedSousProjet.value?.id == sousProjet.id;
          
          return SousProjetCard(
            sousProjet: sousProjet,
            isSelected: isSelected,
            primaryColor: mainColor,
            onTap: () {
              // Navigation vers la page des activités générales liées à ce sous-projet
              Get.to(
                () => QualiticiensActiviteGeneraleList(),
                arguments: {
                  'sousProjetId': sousProjet.id,
                  'sousProjetTitre': sousProjet.titre,
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
      onPressed: () => _controller.refreshSousProjets(),
      backgroundColor: mainColor,
      foregroundColor: Colors.white,
      tooltip: 'Rafraîchir la liste',
      child: const Icon(Icons.refresh),
    );
  }
}
