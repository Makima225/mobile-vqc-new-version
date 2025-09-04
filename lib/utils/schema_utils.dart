

class SchemaUtils {
  /// Créer un schéma de test avec données d'exemple
  static Map<String, dynamic> createTestSchema() {
    return {
      "elements": [
        {
          "type": "table",
          "id": "tbl_test",
          "headers": ["PIEUX", "OK / NOK / NA", "OBS."],
          "rows": [
            [
              {"type": "text", "id": "cell_1", "value": "Implantation / Marquage topographique"},
              {"type": "input", "id": "cell_2", "value": ""},
              {"type": "input", "id": "cell_3", "value": ""}
            ],
            [
              {"type": "text", "id": "cell_4", "value": "Verticalité"},
              {"type": "input", "id": "cell_5", "value": ""},
              {"type": "input", "id": "cell_6", "value": ""}
            ]
          ]
        }
      ]
    };
  }

  /// Créer un tableau par défaut
  static List<Map<String, dynamic>> createDefaultTable() {
    return [
      {
        'headers': ['Élément', 'Spécification', 'Moyen de contrôle', 'Résultat', 'Validation'],
        'rows': [
          ['Dimension A', '10 ± 0.1 mm', '', '', ''],
          ['Dimension B', '20 ± 0.2 mm', '', '', ''],
          ['Surface', 'Lisse', '', '', ''],
        ],
        'type': 'table',
      }
    ];
  }

  /// Convertir le schéma legacy vers le nouveau format
  static void convertLegacySchema(Map<String, dynamic> schema) {
    List<Map<String, dynamic>> tables = [];
    
    if (schema.containsKey('elements') && schema['elements'] is List) {
      tables = _extractTablesFromElements(schema['elements']);
    } else if (schema.containsKey('columns') && schema.containsKey('rows')) {
      tables = _extractTablesFromColumnsRows(schema);
    } else if (schema.keys.isNotEmpty) {
      tables = _extractTablesFromKeys(schema);
    }
    
    if (tables.isEmpty) {
      tables = createDefaultTable();
    }
    
    schema['tables'] = tables;
  }

  static List<Map<String, dynamic>> _extractTablesFromElements(List<dynamic> elements) {
    List<Map<String, dynamic>> tables = [];
    
    for (var element in elements) {
      if (element is Map<String, dynamic> && element['type'] == 'table') {
        List<String> headers = List<String>.from(element['headers'] ?? []);
        List<List<String>> convertedRows = [];
        
        if (element.containsKey('rows') && element['rows'] is List) {
          for (var row in element['rows']) {
            if (row is List) {
              List<String> convertedRow = [];
              for (var cell in row) {
                String cellValue = '';
                if (cell is Map<String, dynamic>) {
                  cellValue = cell['value']?.toString() ?? cell['text']?.toString() ?? '';
                }
                convertedRow.add(cellValue);
              }
              convertedRows.add(convertedRow);
            }
          }
        }
        
        if (headers.isNotEmpty) {
          tables.add({
            'id': element['id'],
            'headers': headers,
            'rows': convertedRows,
          });
        }
      }
    }
    
    return tables;
  }

  static List<Map<String, dynamic>> _extractTablesFromColumnsRows(Map<String, dynamic> schema) {
    List<String> headers = List<String>.from(schema['columns']);
    List<dynamic> rows = schema['rows'];
    
    List<List<String>> convertedRows = [];
    for (var row in rows) {
      List<String> convertedRow = [];
      for (int i = 0; i < headers.length; i++) {
        String value = '';
        if (row is Map && row.containsKey(headers[i])) {
          value = row[headers[i]]?.toString() ?? '';
        } else if (row is List && i < row.length) {
          value = row[i]?.toString() ?? '';
        }
        convertedRow.add(value);
      }
      convertedRows.add(convertedRow);
    }
    
    return [
      {
        'headers': headers,
        'rows': convertedRows,
      }
    ];
  }

  static List<Map<String, dynamic>> _extractTablesFromKeys(Map<String, dynamic> schema) {
    List<String> headers = [];
    List<String> values = [];
    
    schema.forEach((key, value) {
      if (value != null && value is! List && value is! Map) {
        headers.add(key);
        values.add(value.toString());
      }
    });
    
    if (headers.isNotEmpty) {
      return [
        {
          'headers': headers,
          'rows': [values],
        }
      ];
    }
    
    return [];
  }

  /// Extraire les tableaux de façon simple
  static List<Map<String, dynamic>> extractSimpleTables(Map<String, dynamic> schemaData) {
    List<Map<String, dynamic>> tables = [];
    
    try {
      if (schemaData.containsKey('tables') && schemaData['tables'] is List) {
        for (var table in schemaData['tables']) {
          if (table is Map<String, dynamic>) {
            tables.add(table);
          }
        }
      }
      
      if (tables.isEmpty && schemaData.containsKey('elements')) {
        tables = parseElementsToSimpleTables(schemaData['elements']);
      }
      
      if (tables.isEmpty) {
        tables = createDefaultTable();
      }
      
    } catch (e) {
      tables = createDefaultTable();
    }
    
    return tables;
  }

  /// Parser les elements vers des tableaux simples
  static List<Map<String, dynamic>> parseElementsToSimpleTables(dynamic elements) {
    List<Map<String, dynamic>> tables = [];
    
    if (elements is List) {
      for (var element in elements) {
        if (element is Map<String, dynamic> && element['type'] == 'table') {
          
          List<String> headers = [];
          if (element.containsKey('headers') && element['headers'] is List) {
            headers = List<String>.from(element['headers']);
          }
          
          List<List<String>> rows = [];
          if (element.containsKey('rows') && element['rows'] is List) {
            for (var row in element['rows']) {
              if (row is List) {
                List<String> rowValues = [];
                for (var cell in row) {
                  if (cell is Map && cell.containsKey('value')) {
                    rowValues.add(cell['value'].toString());
                  } else {
                    rowValues.add(cell.toString());
                  }
                }
                rows.add(rowValues);
              }
            }
          }
          
          tables.add({
            'headers': headers,
            'rows': rows,
            'type': 'table',
          });
        }
      }
    }
    
    return tables;
  }
}
