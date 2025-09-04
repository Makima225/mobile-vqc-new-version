// Test du parser de schéma avec l'exemple fourni
void testSchemaParser() {
  final String exampleSchema = '''
{
  "elements": [
    {
      "type": "paragraph",
      "text": "",
      "placeholders": []
    },
    {
      "type": "table",
      "id": "tbl_085e4550",
      "headers": ["PIEUX", "OK / NOK / NA", "OBS."],
      "rows": [
        [
          {
            "type": "text",
            "id": "cell_0aa348d9",
            "row": 1,
            "col": 0,
            "text": "Implantation / Marquage topographique",
            "placeholders": [],
            "value": null
          },
          {
            "type": "input",
            "id": "cell_4ca948d1",
            "row": 1,
            "col": 1,
            "text": null,
            "placeholders": [],
            "value": ""
          },
          {
            "type": "input",
            "id": "cell_83be1002",
            "row": 1,
            "col": 2,
            "text": null,
            "placeholders": [],
            "value": ""
          }
        ],
        [
          {
            "type": "text",
            "id": "cell_f4bf5cb4",
            "row": 2,
            "col": 0,
            "text": "Verticalité",
            "placeholders": [],
            "value": null
          },
          {
            "type": "input",
            "id": "cell_3ddde0ae",
            "row": 2,
            "col": 1,
            "text": null,
            "placeholders": [],
            "value": ""
          },
          {
            "type": "input",
            "id": "cell_fdf28435",
            "row": 2,
            "col": 2,
            "text": null,
            "placeholders": [],
            "value": ""
          }
        ]
      ]
    },
    {
      "type": "paragraph",
      "text": "",
      "placeholders": []
    }
  ]
}
''';

  print('🧪 Test du parser de schéma');
  print('📝 Schéma d\'entrée: $exampleSchema');
  
  // Ce test devrait extraire:
  // - 1 tableau avec ID "tbl_085e4550"
  // - Headers: ["PIEUX", "OK / NOK / NA", "OBS."]
  // - 2 lignes de données
  // - Mélange de cellules "text" (lecture seule) et "input" (éditables)
}
