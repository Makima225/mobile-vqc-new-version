import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/qualiticiens/template_controller.dart';
import '../../widgets/template_fichecontrole_card.dart';
import '../../widgets/error_state_widget.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/loading_widget.dart';
import '../../models/core/template_model.dart';

class QualiticiensTemplateListScreen extends StatelessWidget {
  final TemplateController _controller = Get.put(TemplateController());
  
  // Couleur principale de l'application
  static const Color mainColor = Colors.deepPurple;

  QualiticiensTemplateListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // AppBar avec design moderne
          _buildSliverAppBar(),
          
          // Barre de recherche et filtres
          SliverToBoxAdapter(
            child: _buildSearchAndFilters(),
          ),
          
         
          
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
          _controller.selectedActiviteSpecifiqueId != null 
            ? 'Templates - ${_controller.selectedActiviteSpecifiqueTitre}'
            : 'Templates Fiche Contrôle',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                mainColor,
                mainColor.withOpacity(0.8),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
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
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            )
          : IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _controller.refreshTemplates,
              tooltip: 'Actualiser',
            )
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Barre de recherche
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              onChanged: _controller.updateSearchQuery,
              decoration: InputDecoration(
                hintText: 'Rechercher un template...',
                prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                suffixIcon: Obx(() => _controller.searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => _controller.updateSearchQuery(''),
                    )
                  : const SizedBox()),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Filtres par type
          Row(
            children: [
             
              
            
              // Bouton effacer filtres
              Obx(() => _controller.searchQuery.isNotEmpty || 
                         _controller.selectedTypeFilter != null
                ? TextButton.icon(
                    onPressed: _controller.clearFilters,
                    icon: const Icon(Icons.clear_all, size: 16),
                    label: const Text('Effacer', style: TextStyle(fontSize: 12)),
                  )
                : const SizedBox()),
            ],
          ),
        ],
      ),
    );
  }



  

  

  Widget _buildMainContent() {
    // État de chargement
    if (_controller.isLoading && !_controller.hasData) {
      return const SizedBox(
        height: 400,
        child: LoadingWidget(message: 'Chargement des templates...'),
      );
    }

    // État d'erreur
    if (_controller.hasError && !_controller.hasData) {
      return SizedBox(
        height: 400,
        child: ErrorStateWidget(
          message: _controller.errorMessage,
          onRetry: _controller.retryLoading,
          primaryColor: mainColor,
        ),
      );
    }
    
    // État vide
    if (!_controller.hasFilteredData) {
      return SizedBox(
        height: 400,
        child: EmptyStateWidget(
          title: _controller.searchQuery.isNotEmpty || _controller.selectedTypeFilter != null
              ? 'Aucun template trouvé'
              : 'Aucun template disponible',
          subtitle: _controller.searchQuery.isNotEmpty || _controller.selectedTypeFilter != null
              ? 'Essayez d\'ajuster vos critères de recherche.'
              : 'Aucun template n\'est configuré pour cette activité spécifique.',
          icon: Icons.description_outlined,
          onRefresh: _controller.refreshTemplates,
          refreshText: 'Actualiser',
          primaryColor: mainColor,
        ),
      );
    }

    return Column(
      children: [
        // Message de rafraîchissement
        if (_controller.isLoading && _controller.hasData)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: mainColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(mainColor),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Actualisation en cours...',
                  style: TextStyle(
                    color: mainColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

        // Liste des templates
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _controller.filteredTemplates.length,
            itemBuilder: (context, index) {
              final template = _controller.filteredTemplates[index];
              final isSelected = _controller.selectedTemplate?.id == template.id;
              
              return TemplateFichecontroleCard(
                template: template,
                isSelected: isSelected,
                primaryColor: mainColor,
                onTap: () => _controller.selectTemplate(template),
                onDownload: () => _downloadTemplate(template),
                onEdit: () => _editTemplate(template),
                onDelete: () => _deleteTemplate(template),
              );
            },
          ),
        ),

        // Espacement en bas
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildFloatingActionButton() {
    return Obx(() => _controller.isPerformingAction
      ? Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: mainColor.withOpacity(0.7),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
        )
      : FloatingActionButton(
          onPressed: _controller.refreshTemplates,
          backgroundColor: mainColor,
          child: const Icon(Icons.refresh, color: Colors.white),
          tooltip: 'Actualiser les templates',
        ));
  }

  // Actions sur les templates
  void _downloadTemplate(TemplateFichecontrole template) async {
    final success = await _controller.downloadTemplate(template);
    if (success) {
      Get.snackbar(
        'Succès',
        'Template "${template.nom}" téléchargé avec succès',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
      );
    }
  }

  void _editTemplate(TemplateFichecontrole template) {
    // TODO: Naviguer vers la page d'édition
    Get.snackbar(
      'Info',
      'Fonctionnalité d\'édition en cours de développement',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _deleteTemplate(TemplateFichecontrole template) {
    Get.dialog(
      AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer le template "${template.nom}" ?\n\nCette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              final success = await _controller.deleteTemplate(template.id!);
              if (success) {
                Get.snackbar(
                  'Succès',
                  'Template supprimé avec succès',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green.shade100,
                  colorText: Colors.green.shade800,
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}