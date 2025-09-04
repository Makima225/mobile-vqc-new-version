import 'package:flutter/material.dart';

class SchemaTableWidget extends StatefulWidget {
  final Map<String, dynamic> tableData;
  final int tableIndex;
  final Function(int tableIndex, int rowIndex, int colIndex, String value) onCellChanged;

  const SchemaTableWidget({
    super.key,
    required this.tableData,
    required this.tableIndex,
    required this.onCellChanged,
  });

  @override
  State<SchemaTableWidget> createState() => _SchemaTableWidgetState();
}

class _SchemaTableWidgetState extends State<SchemaTableWidget> {
  final Map<String, TextEditingController> _controllers = {};

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
        _controllers[controllerKey]!.addListener(() {
          widget.onCellChanged(
            widget.tableIndex,
            rowIndex,
            colIndex,
            _controllers[controllerKey]!.text,
          );
        });
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
              String cellValue = cell['text']?.toString() ?? cell['value']?.toString() ?? '';
              stringRow.add(cellValue);
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
          columnSpacing: 20,
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
    
    Widget inputWidget;
    
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
    
    return Container(
      constraints: const BoxConstraints(minWidth: 150, minHeight: 45),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: inputWidget,
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
        }
      },
    );
  }

  Widget _buildTextInput(String controllerKey) {
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

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}
