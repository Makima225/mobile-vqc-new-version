import 'package:flutter/material.dart';
import '../models/core/sous_projet_model.dart';

class SousProjetCard extends StatelessWidget {
  final SousProjet sousProjet;
  final VoidCallback onTap;
  final Color? primaryColor;
  final bool isSelected;

  const SousProjetCard({
    super.key,
    required this.sousProjet,
    required this.onTap,
    this.primaryColor,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = primaryColor ?? Colors.deepPurple;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        borderRadius: BorderRadius.circular(16),
        elevation: isSelected ? 8 : 4,
        shadowColor: color.withOpacity(0.3),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: color.withOpacity(0.1),
          highlightColor: color.withOpacity(0.05),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: isSelected ? color.withOpacity(0.05) : Colors.white,
              border: isSelected 
                ? Border.all(color: color.withOpacity(0.3), width: 2)
                : null,
            ),
            child: Row(
              children: [
                // Icône avec container décoratif
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: color.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.apartment_rounded,
                    color: color,
                    size: 24,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Contenu principal
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sousProjet.titre,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.grey[800],
                        ),
                      ),
                      
                      const SizedBox(height: 6),
                      
                      Text(
                        'Projet #${sousProjet.projetId}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      
                      const SizedBox(height: 4),
                      
                      Text(
                        'Appuyez pour accéder aux détails',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Icône de navigation
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: color,
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
}
