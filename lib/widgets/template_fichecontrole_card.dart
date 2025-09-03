import 'package:flutter/material.dart';
import '../models/core/template_model.dart';

class TemplateFichecontroleCard extends StatelessWidget {
  final TemplateFichecontrole template;
  final bool isSelected;
  final Color primaryColor;
  final VoidCallback? onTap;
  final VoidCallback? onDownload;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TemplateFichecontroleCard({
    super.key,
    required this.template,
    this.isSelected = false,
    required this.primaryColor,
    this.onTap,
    this.onDownload,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        elevation: isSelected ? 8 : 2,
        borderRadius: BorderRadius.circular(16),
        shadowColor: primaryColor.withOpacity(0.3),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected 
                  ? primaryColor 
                  : Colors.grey.withOpacity(0.2),
                width: isSelected ? 2 : 1,
              ),
              gradient: isSelected 
                ? LinearGradient(
                    colors: [
                      primaryColor.withOpacity(0.1),
                      primaryColor.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
              color: isSelected ? null : Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête avec titre et type
                Row(
                  children: [
                    // Icône du type de fichier
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getTypeColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getTypeIcon(),
                        color: _getTypeColor(),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Titre et type
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            template.nom,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? primaryColor : Colors.black87,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getTypeColor().withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              template.typeDisplayName,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: _getTypeColor(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Menu d'actions
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        color: isSelected ? primaryColor : Colors.grey[600],
                      ),
                      onSelected: (value) {
                        switch (value) {
                          case 'download':
                            onDownload?.call();
                            break;
                          case 'edit':
                            onEdit?.call();
                            break;
                          case 'delete':
                            onDelete?.call();
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'download',
                          child: Row(
                            children: [
                              Icon(Icons.download, size: 20),
                              SizedBox(width: 8),
                              Text('Télécharger'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 20),
                              SizedBox(width: 8),
                              Text('Modifier'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 20, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Supprimer', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Informations détaillées
                Row(
                  children: [
                    // Quantité
                    _buildInfoChip(
                      icon: Icons.inventory_2_outlined,
                      label: 'Quantité',
                      value: '${template.quantite}',
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 12),
                    
                    // Schema disponible
                    if (template.hasSchema)
                      _buildInfoChip(
                        icon: Icons.schema_outlined,
                        label: 'Schema',
                        value: 'Oui',
                        color: Colors.green,
                      ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Date de création
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Créé le ${_formatDate(template.createdAt)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            '$label: $value',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor() {
    switch (template.typeTemplate) {
      case TypeTemplate.pdf:
        return Colors.red;
      case TypeTemplate.docx:
        return Colors.blue;
    }
  }

  IconData _getTypeIcon() {
    switch (template.typeTemplate) {
      case TypeTemplate.pdf:
        return Icons.picture_as_pdf;
      case TypeTemplate.docx:
        return Icons.description;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
