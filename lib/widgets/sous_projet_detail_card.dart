import 'package:flutter/material.dart';
import '../models/core/sous_projet_model.dart';

class SousProjetDetailCard extends StatelessWidget {
  final SousProjet sousProjet;
  final SousProjet? details;
  final bool isLoading;
  final Color? primaryColor;

  const SousProjetDetailCard({
    super.key,
    required this.sousProjet,
    this.details,
    this.isLoading = false,
    this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = primaryColor ?? Colors.deepPurple;
    
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.05),
            color.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.info_outline_rounded,
                    color: color,
                    size: 20,
                  ),
                ),
                
                const SizedBox(width: 12),
                
                Expanded(
                  child: Text(
                    'Détails du sous-projet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
                
                if (isLoading)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: color,
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Divider
            Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withOpacity(0.3),
                    color.withOpacity(0.1),
                    color.withOpacity(0.3),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Informations principales
            _buildDetailRow(
              'Titre',
              sousProjet.titre,
              Icons.title_rounded,
              color,
            ),
            
            const SizedBox(height: 12),
            
            _buildDetailRow(
              'Projet parent',
              'Projet #${sousProjet.projetId}',
              Icons.account_tree_rounded,
              color,
            ),
            
            // Informations supplémentaires si disponibles
            if (details != null) ...[
              const SizedBox(height: 16),
              
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informations supplémentaires',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: color,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    _buildDetailRow(
                      'ID du sous-projet',
                      '#${details!.id}',
                      Icons.tag_rounded,
                      color,
                      isSubDetail: true,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    _buildDetailRow(
                      'Statut',
                      'Actif',
                      Icons.check_circle_outline_rounded,
                      color,
                      isSubDetail: true,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    IconData icon,
    Color color, {
    bool isSubDetail = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: color.withOpacity(isSubDetail ? 0.05 : 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: isSubDetail ? 14 : 16,
            color: color,
          ),
        ),
        
        const SizedBox(width: 12),
        
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: isSubDetail ? 12 : 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
              
              const SizedBox(height: 2),
              
              Text(
                value,
                style: TextStyle(
                  fontSize: isSubDetail ? 13 : 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
