import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/qualiticiens/activite_specifique_controller.dart';
import '../../widgets/activite_specifique_card.dart';
import '../../widgets/error_state_widget.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/loading_widget.dart';

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
        
        // Informations du filtre actuel
        if (_controller.selectedActiviteGeneraleId != null)
          _buildFilterInfo(),
        
        // Statistiques
        _buildStatsCard(),
        
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

  Widget _buildFilterInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            mainColor.withOpacity(0.1),
            mainColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: mainColor.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.filter_list_outlined,
            color: mainColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filtre actif',
                  style: TextStyle(
                    color: mainColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Activité générale: ${_controller.selectedActiviteGeneraleTitre}',
                  style: TextStyle(
                    color: mainColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: _controller.clearActiviteGeneraleFilter,
            icon: Icon(Icons.clear, size: 16, color: mainColor),
            label: Text(
              'Effacer',
              style: TextStyle(
                color: mainColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: mainColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.task_alt,
              color: mainColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Activités spécifiques',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_controller.activitesSpecifiques.length} activité(s)',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          if (_controller.selectedActiviteGeneraleId != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: mainColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: mainColor.withOpacity(0.3),
                ),
              ),
              child: Text(
                'Filtrées',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: mainColor,
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
              // Navigation vers les fiches de contrôle ou autres fonctionnalités futures
              _showActiviteSpecifiqueActions(activite);
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

  void _showActiviteSpecifiqueActions(activite) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              activite.titre,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.info_outline, color: mainColor),
              title: const Text('Voir les détails'),
              onTap: () {
                Get.back();
                _showActiviteDetails(activite);
              },
            ),
            ListTile(
              leading: Icon(Icons.assignment_outlined, color: mainColor),
              title: const Text('Voir les fiches de contrôle'),
              onTap: () {
                Get.back();
                Get.snackbar(
                  'Information',
                  'Fonctionnalité en cours de développement',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showActiviteDetails(activite) {
    Get.dialog(
      AlertDialog(
        title: Text(activite.titre),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${activite.id}'),
            const SizedBox(height: 8),
            Text('Activité générale ID: ${activite.activiteGeneraleId}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}