import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/qualiticiens/activite_specifique_controller.dart';
import '../../widgets/activite_specifique_card.dart';
import '../../widgets/error_state_widget.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/loading_widget.dart';
import 'qualiticien_template_list_screen.dart';

class QualiticiensActiviteSpecifiqueList extends StatelessWidget {
  final ActiviteSpecifiqueController _controller = Get.put(ActiviteSpecifiqueController());
  
  // Couleur principale de l'application
  static const Color mainColor = Colors.deepPurple;

  QualiticiensActiviteSpecifiqueList({super.key});

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
        title: Text(
          _controller.selectedActiviteGeneraleId != null 
            ? 'Activités - ${_controller.selectedActiviteGeneraleTitre}'
            : 'Activités Spécifiques',
          style: const TextStyle(
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
        // Bouton pour effacer le filtre
        if (_controller.selectedActiviteGeneraleId != null)
          IconButton(
            icon: const Icon(Icons.clear_outlined, color: Colors.white),
            onPressed: _controller.clearActiviteGeneraleFilter,
            tooltip: 'Afficher toutes les activités spécifiques',
          ),
        
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
              onPressed: _controller.refreshActivitesSpecifiques,
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
          message: 'Chargement des activités spécifiques...',
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
    
    if (_controller.activitesSpecifiques.isEmpty) {
      return SizedBox(
        height: 400,
        child: EmptyStateWidget(
          title: 'Aucune activité spécifique trouvée',
          subtitle: _controller.selectedActiviteGeneraleId != null
            ? 'Aucune activité spécifique n\'est liée à cette activité générale.'
            : 'Aucune activité spécifique n\'est disponible pour votre compte.',
          icon: Icons.task_outlined,
          onRefresh: _controller.refreshActivitesSpecifiques,
          refreshText: 'Actualiser',
          primaryColor: mainColor,
        ),
      );
    }
    
    return Column(
      children: [
        // Message de rafraîchissement
        _buildRefreshHint(),
        
      
        
      
        
        // Liste des activités spécifiques
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
      onRefresh: _controller.refreshActivitesSpecifiques,
      color: mainColor,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _controller.activitesSpecifiques.length,
        itemBuilder: (context, index) {
          final activite = _controller.activitesSpecifiques[index];
          
          return ActiviteSpecifiqueCard(
            activite: activite,
            isSelected: false, // Pas de sélection pour les activités spécifiques
            primaryColor: mainColor,
            onTap: () {
              // Navigation directe vers la page des templates
              Get.to(
                () => QualiticiensTemplateListScreen(),
                arguments: {
                  'activiteSpecifiqueId': activite.id,
                  'activiteSpecifiqueTitre': activite.titre,
                },
                transition: Transition.rightToLeft,
                duration: const Duration(milliseconds: 300),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () => _controller.refreshActivitesSpecifiques(),
      backgroundColor: mainColor,
      foregroundColor: Colors.white,
      tooltip: 'Rafraîchir la liste',
      child: const Icon(Icons.refresh),
    );
  }
}