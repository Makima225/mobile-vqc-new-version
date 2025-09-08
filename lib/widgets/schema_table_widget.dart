import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'signaler_anomalie_dialog.dart';

class SchemaTableWidget extends StatefulWidget {
  final Map<String, dynamic> tableData;
  final int tableIndex;
  final int ficheControleId;
  final Function(int tableIndex, int rowIndex, int colIndex, String value) onCellChanged;
  // Nouveau: callback pour remonter une anomalie créée dans la table
  final void Function(Map<String, dynamic> anomalie)? onAnomalieAdded;

  const SchemaTableWidget({
    super.key,
    required this.tableData,
    required this.tableIndex,
    required this.ficheControleId,
    required this.onCellChanged,
    this.onAnomalieAdded,
  });

  @override
  State<SchemaTableWidget> createState() => _SchemaTableWidgetState();
}

class _SchemaTableWidgetState extends State<SchemaTableWidget> {
  final Map<String, TextEditingController> _controllers = {};
  final ImagePicker _picker = ImagePicker();
  final List<File> _capturedPhotos = []; // Liste des photos prises

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    List<String> headers = List<String>.from(widget.tableData['headers'] ?? []);
    List<List<String>> rows = _extractRows();
    
    for (int rowIndex = 0; rowIndex < rows.length; rowIndex++) {
      for (int colIndex = 0; colIndex < headers.length; colIndex++) {
        String controllerKey = '${widget.tableIndex}_${rowIndex}_$colIndex';
        String value = colIndex < rows[rowIndex].length ? rows[rowIndex][colIndex] : '';
        
        _controllers[controllerKey] = TextEditingController(text: value);
        
        // CORRECTION: Ne sauvegarder que quand l'utilisateur a fini de saisir (perte de focus)
        // Au lieu d'addListener qui se déclenche à chaque caractère
        // Pas de listener ici, on sauvegarde seulement sur onChanged du TextField
      }
    }
  }

  List<List<String>> _extractRows() {
    List<List<String>> rows = [];
    if (widget.tableData['rows'] is List) {
      for (var row in widget.tableData['rows']) {
        if (row is List) {
          List<String> stringRow = [];
          for (var cell in row) {
            if (cell is Map<String, dynamic>) {
              // CORRECTION: Prioriser 'value' pour les cellules input, puis 'text'
              String cellValue = '';
              if (cell['type'] == 'input') {
                // Pour les cellules input, utiliser 'value' (données saisies)
                cellValue = cell['value']?.toString() ?? '';
              } else {
                // Pour les cellules text, utiliser 'text' (contenu statique)
                cellValue = cell['text']?.toString() ?? '';
              }
              stringRow.add(cellValue);
              
              // Log pour déboguer
              print('🔍 Cellule extraite: type=${cell['type']}, value="${cell['value']}", text="${cell['text']}" → résultat="$cellValue"');
            } else {
              stringRow.add(cell?.toString() ?? '');
            }
          }
          rows.add(stringRow);
        }
      }
    }
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    List<String> headers = List<String>.from(widget.tableData['headers'] ?? []);
    List<List<String>> rows = _extractRows();

    if (headers.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Tableau invalide'),
        ),
      );
    }

    return Card(
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTableHeader(),
          _buildTableContent(headers, rows),
          _buildAnomalieButton(),
          if (_capturedPhotos.isNotEmpty) _buildPhotosSection(),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[600]!, Colors.blue[500]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.table_chart, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Tableau ${widget.tableIndex + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableContent(List<String> headers, List<List<String>> rows) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          border: TableBorder.all(color: Colors.grey[300]!, width: 1),
          columnSpacing: 30,
          headingRowColor: WidgetStateProperty.all(Colors.blue[50]),
          columns: headers.map((header) {
            return DataColumn(
              label: Container(
                constraints: const BoxConstraints(minWidth: 150),
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  header,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }).toList(),
          rows: rows.asMap().entries.map((entry) {
            int rowIndex = entry.key;
            List<String> rowData = entry.value;
            
            return DataRow(
              cells: headers.asMap().entries.map((headerEntry) {
                int colIndex = headerEntry.key;
                String header = headerEntry.value;
                String cellValue = colIndex < rowData.length ? rowData[colIndex] : '';
                
                return DataCell(_buildEditableCell(cellValue, rowIndex, colIndex, header));
              }).toList(),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildEditableCell(String value, int rowIndex, int colIndex, String header) {
    String controllerKey = '${widget.tableIndex}_${rowIndex}_$colIndex';
    
    // ⚠️ RÈGLE IMPORTANTE : Si la cellule a déjà du texte (valeur prédéfinie), 
    // elle doit être en lecture seule (read-only)
    bool isReadOnly = value.isNotEmpty && value.trim().isNotEmpty;
    
    Widget inputWidget;
    
    if (isReadOnly) {
      // 📖 Cellule en lecture seule - Affichage uniquement
      inputWidget = _buildReadOnlyCell(value);
    } else {
      // ✏️ Cellule modifiable - Saisie utilisateur possible
      
      // Détection automatique des dropdowns avec "/"
      if (header.contains('/')) {
        List<String> options = _extractOptionsFromHeader(header);
        inputWidget = _buildDynamicDropdown(controllerKey, value, options);
      }
      // Dropdown pour moyens de contrôle
      else if (header.toLowerCase().contains('contrôle') || header.toLowerCase().contains('controle')) {
        inputWidget = _buildControlDropdown(controllerKey, value);
      }
      // TextField normal
      else {
        inputWidget = _buildTextInput(controllerKey);
      }
    }
    
    return Container(
      constraints: const BoxConstraints(minWidth: 150, minHeight: 45),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: inputWidget,
    );
  }

  /// Widget pour afficher une cellule en lecture seule (read-only)
  Widget _buildReadOnlyCell(String value) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100], // Fond gris clair pour indiquer lecture seule
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      width: double.infinity,
      child: Row(
        children: [
          Icon(
            Icons.lock_outline, 
            size: 16, 
            color: Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  List<String> _extractOptionsFromHeader(String header) {
    List<String> rawOptions = header.split('/').map((option) => option.trim()).toList();
    List<String> cleanOptions = [''];
    cleanOptions.addAll(rawOptions.where((option) => option.isNotEmpty));
    return cleanOptions;
  }

  Widget _buildDynamicDropdown(String controllerKey, String currentValue, List<String> options) {
    return DropdownButtonFormField<String>(
      value: options.contains(currentValue) ? currentValue : '',
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: Colors.orange[300]!, width: 1),
        ),
        filled: true,
        fillColor: Colors.orange[50]!,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: options.map((option) {
        return DropdownMenuItem<String>(
          value: option,
          child: Text(
            option.isEmpty ? 'Choisir...' : option,
            style: TextStyle(
              fontSize: 14,
              fontWeight: option.isEmpty ? FontWeight.normal : FontWeight.bold,
              color: _getOptionColor(option),
            ),
          ),
        );
      }).toList(),
      onChanged: (String? newValue) {
        if (newValue != null) {
          _controllers[controllerKey]!.text = newValue;
          
          // AJOUT: Notifier le parent comme pour les TextFields
          final parts = controllerKey.split('_');
          if (parts.length >= 3) {
            final rowIndex = int.tryParse(parts[1]) ?? 0;
            final colIndex = int.tryParse(parts[2]) ?? 0;
            widget.onCellChanged(0, rowIndex, colIndex, newValue);
          }
        }
      },
    );
  }

  Widget _buildControlDropdown(String controllerKey, String currentValue) {
    List<String> options = [
      '',
      'Visuel',
      'Mesure',
      'Test',
      'Contrôle dimensionnel',
      'Vérification documentaire',
      'Essai fonctionnel',
    ];
    
    return DropdownButtonFormField<String>(
      value: options.contains(currentValue) ? currentValue : '',
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: Colors.green[300]!, width: 1),
        ),
        filled: true,
        fillColor: Colors.green[50],
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: options.map((option) {
        return DropdownMenuItem<String>(
          value: option,
          child: Text(
            option.isEmpty ? 'Sélectionner...' : option,
            style: TextStyle(
              fontSize: 14,
              color: option.isEmpty ? Colors.grey[600] : Colors.black,
            ),
          ),
        );
      }).toList(),
      onChanged: (String? newValue) {
        if (newValue != null) {
          _controllers[controllerKey]!.text = newValue;
          
          // AJOUT: Notifier le parent comme pour les TextFields
          final parts = controllerKey.split('_');
          if (parts.length >= 3) {
            final rowIndex = int.tryParse(parts[1]) ?? 0;
            final colIndex = int.tryParse(parts[2]) ?? 0;
            widget.onCellChanged(0, rowIndex, colIndex, newValue);
          }
        }
      },
    );
  }

  Widget _buildTextInput(String controllerKey) {
    // Extraire les index de la clé du controller
    List<String> parts = controllerKey.split('_');
    int rowIndex = int.parse(parts[1]);
    int colIndex = int.parse(parts[2]);
    
    return TextField(
      controller: _controllers[controllerKey],
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: Colors.blue[300]!, width: 1),
        ),
        hintText: 'Saisir...',
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        filled: true,
        fillColor: Colors.blue[50],
      ),
      style: const TextStyle(fontSize: 14),
      textAlign: TextAlign.center,
      // CORRECTION: Sauvegarder seulement quand l'utilisateur a fini de modifier
      onChanged: (value) {
        // Appeler le callback parent pour sauvegarder les données
        widget.onCellChanged(
          widget.tableIndex,
          rowIndex,
          colIndex,
          value,
        );
      },
    );
  }

  Color _getOptionColor(String option) {
    String lowerOption = option.toLowerCase();
    
    if (lowerOption == 'ok' || lowerOption == 'conforme' || lowerOption == 'oui') {
      return Colors.green[700]!;
    } else if (lowerOption == 'nok' || lowerOption == 'non conforme' || lowerOption == 'non') {
      return Colors.red[700]!;
    } else if (lowerOption == 'na' || lowerOption == 'n/a' || lowerOption == 'sans objet') {
      return Colors.orange[700]!;
    } else if (option.isEmpty) {
      return Colors.grey[600]!;
    } else {
      return Colors.black;
    }
  }

  Widget _buildAnomalieButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Bouton Signaler anomalie
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _showAnomalieDialog(),
              icon: const Icon(Icons.warning_outlined, size: 20),
              label: const Text(
                'Signaler une anomalie',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Bouton Prendre une photo
         
        ],
      ),
    );
  }

  /// Section d'affichage des photos capturées
  Widget _buildPhotosSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.photo_camera, color: Colors.blue[700], size: 20),
              const SizedBox(width: 8),
              Text(
                'Photos capturées (${_capturedPhotos.length})',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[700],
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _capturedPhotos.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(right: 12),
                  child: Stack(
                    children: [
                      // Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          _capturedPhotos[index],
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                      // Bouton de suppression
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _supprimerPhoto(index),
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(4),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAnomalieDialog() async {
    final result = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return SignalerAnomalieDialog(
          ficheControleId: widget.ficheControleId,
          tableIndex: widget.tableIndex,
          primaryColor: Colors.orange[600]!,
        );
      },
    );

    // Si une anomalie a été signalée, on la transmet à la callback
    if (result != null && result is Map<String, dynamic>) {
      widget.onAnomalieAdded?.call(result);
    }
  }

  /// Prendre une photo avec la caméra
  Future<void> _prendrePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (photo != null) {
        final File photoFile = File(photo.path);
        setState(() {
          _capturedPhotos.add(photoFile);
        });
        
        // Affichage d'un message de confirmation
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('📸 Photo ajoutée (${_capturedPhotos.length} photo(s))'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Erreur lors de la prise de photo: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Erreur lors de la prise de photo'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Supprimer une photo de la liste
  void _supprimerPhoto(int index) {
    setState(() {
      _capturedPhotos.removeAt(index);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🗑️ Photo supprimée (${_capturedPhotos.length} photo(s) restante(s))'),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}
