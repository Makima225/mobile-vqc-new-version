import 'package:flutter/material.dart';
import '../models/core/entete_model.dart';

class EnteteCard extends StatefulWidget {
  final List<Entete> entetes;
  final Map<int, String> enteteValues;
  final Function(int enteteId, String value) onValueChanged;
  final Color primaryColor;

  const EnteteCard({
    super.key,
    required this.entetes,
    required this.enteteValues,
    required this.onValueChanged,
    this.primaryColor = Colors.deepPurple,
  });

  @override
  State<EnteteCard> createState() => _EnteteCardState();
}

class _EnteteCardState extends State<EnteteCard> {
  final Map<int, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    for (final entete in widget.entetes) {
      if (entete.id != null) {
        final controller = TextEditingController(
          text: widget.enteteValues[entete.id] ?? '',
        );
        controller.addListener(() {
          widget.onValueChanged(entete.id!, controller.text);
        });
        _controllers[entete.id!] = controller;
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.entetes.isEmpty) {
      return Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(
                Icons.info_outline,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 12),
              Text(
                'Aucun entête disponible',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ce template ne contient aucun entête à remplir.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête de la card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.primaryColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.assignment_outlined,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Entêtes à remplir',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${widget.entetes.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Liste des entêtes
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: widget.entetes.asMap().entries.map((entry) {
                final index = entry.key;
                final entete = entry.value;
                final controller = _controllers[entete.id];

                return Container(
                  margin: EdgeInsets.only(bottom: index < widget.entetes.length - 1 ? 16 : 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Titre de l'entête
                      Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: widget.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: widget.primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              entete.titre,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Champ de saisie
                      if (controller != null)
                        TextField(
                          controller: controller,
                          decoration: InputDecoration(
                            hintText: 'Saisir la valeur pour "${entete.titre}"',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: widget.primaryColor),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            suffixIcon: controller.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 20),
                                    onPressed: () {
                                      controller.clear();
                                    },
                                  )
                                : null,
                          ),
                          maxLines: entete.titre.toLowerCase().contains('description') ||
                                  entete.titre.toLowerCase().contains('commentaire') ||
                                  entete.titre.toLowerCase().contains('remarque')
                              ? 3
                              : 1,
                        ),

                      // Séparateur (sauf pour le dernier élément)
                      if (index < widget.entetes.length - 1) ...[
                        const SizedBox(height: 16),
                        Divider(
                          color: Colors.grey[200],
                          thickness: 1,
                        ),
                      ],
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
