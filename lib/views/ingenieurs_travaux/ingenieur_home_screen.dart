import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/ingenieurs_travaux/ingenieur_home_page_controller.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_state_widget.dart';
import '../../widgets/empty_state_widget.dart';

class IngenieurHomeScreen extends StatelessWidget {
  final ActiviteGeneraleController _controller = Get.put(ActiviteGeneraleController());
  
  // Couleur principale de l'application
  static const Color mainColor = Colors.deepPurple;

  IngenieurHomeScreen({super.key});

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
      floatingActionButton: Obx(() => _buildFloatingActionButton()),
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
                right: 40,
                top: 40,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: () => _controller.refreshData(),
        ),
      ],
    );
  }

  Widget _buildMainContent() {
    if (_controller.isLoading.value) {
      return const LoadingWidget(
        message: "Chargement des activités générales...",
      );
    }
    
    if (_controller.hasError) {
      return ErrorStateWidget(
        message: _controller.errorMessage.value,
        onRetry: () => _controller.refreshData(),
      );
    }
    
    if (!_controller.hasData) {
      return const EmptyStateWidget(
        icon: Icons.work_outline,
        title: "Aucune activité générale",
        subtitle: "Aucune activité générale n'a été trouvée pour le moment.",
      );
    }

    return _buildActivitesList();
  }

  Widget _buildActivitesList() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec statistiques
          _buildStatsHeader(),
          
          const SizedBox(height: 20),
          
          // Liste des activités
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _controller.activitesGenerales.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final activite = _controller.activitesGenerales[index];
              return _buildActiviteCard(activite, index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatsHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
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
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.analytics_outlined,
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
                  'Total des activités',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_controller.activitesGenerales.length}',
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiviteCard(dynamic activite, int index) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: mainColor.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _navigateToActiviteSpecifiques(activite),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Icône avec numéro
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [mainColor, mainColor.withOpacity(0.7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Contenu
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activite['titre'] ?? 'Titre non disponible',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      if (activite['description'] != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          activite['description'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      
                      const SizedBox(height: 8),
                      
                      // Badge de statut ou informations supplémentaires
                      if (activite['statut'] != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(activite['statut']).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            activite['statut'],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _getStatusColor(activite['statut']),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                
                // Flèche
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey[600],
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    if (_controller.isRefreshing.value) {
      return FloatingActionButton(
        onPressed: null,
        backgroundColor: Colors.grey,
        child: const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }

    return FloatingActionButton(
      onPressed: () => _controller.refreshData(),
      backgroundColor: mainColor,
      child: const Icon(Icons.refresh, color: Colors.white),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'actif':
      case 'active':
      case 'en cours':
        return Colors.green;
      case 'en attente':
      case 'pending':
        return Colors.orange;
      case 'terminé':
      case 'completed':
        return Colors.blue;
      case 'suspendu':
      case 'suspended':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _navigateToActiviteSpecifiques(dynamic activite) {
    final int? activiteGeneraleId = activite['id'];
    
    if (activiteGeneraleId == null) {
      Get.snackbar(
        "❌ Erreur",
        "ID de l'activité non valide",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // TODO: Remplacer par votre page de navigation réelle
    // Get.to(() => IngenieurActiviteSpecifiquesPage(
    //   activiteGeneraleId: activiteGeneraleId,
    // ));
    
    // Temporaire : Navigation vers une page générique ou message
    Get.snackbar(
      "📋 Navigation",
      "Ouverture des activités spécifiques pour: ${activite['titre']}",
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
