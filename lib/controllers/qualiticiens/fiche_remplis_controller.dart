import 'dart:async';
import 'dart:io';
import 'package:get/get.dart';
import '../../models/core/template_model.dart';
import '../../models/core/entete_model.dart';
import '../../services/core/entete_by_template_service.dart';
import '../../utils/schema_utils.dart';

class FicheRemplisController extends GetxController {
	// Services
	late EnteteByTemplateService enteteService;

	// State
	var entetes = <Entete>[].obs;
	var enteteValues = <int, String>{}.obs;
	var isLoading = false.obs;
	var errorMessage = RxnString();
	var currentStep = 0.obs;
	var schemaData = <String, dynamic>{}.obs;
	var photoObligatoire = Rxn<File>();
	var anomalies = <Map<String, dynamic>>[].obs;
	Timer? saveTimer;
	var pendingChanges = <String, String>{}.obs;

	@override
	void onInit() {
		super.onInit();
		enteteService = Get.find<EnteteByTemplateService>();
		loadEntetes();
	}

	@override
	void onClose() {
		saveTimer?.cancel();
		super.onClose();
	}

	Future<void> prendrePhotoObligatoire() async {
		// This should be called from the view, which handles ImagePicker
		// Controller only stores the File
	}

	void ajouterAnomalie(Map<String, dynamic> anomalie) {
		anomalies.add(anomalie);
	}

	void onSchemaDataChanged(Map<String, dynamic> data) {
		schemaData.value = data;
	}

	void synchronizeTableData() {
		// ...existing logic from view...
		// Synchronize 'elements' and 'tables' in schemaData
	}

	Future<void> loadEntetes() async {
		final TemplateFichecontrole? template = Get.arguments as TemplateFichecontrole?;
		if (template?.id == null) {
			errorMessage.value = 'Template invalide';
			return;
		}
		isLoading.value = true;
		errorMessage.value = null;
		initializeTableFromSchema(template!);
		try {
			final entetesList = await enteteService.getEntetesByTemplate(template.id!);
			entetes.assignAll(entetesList);
			isLoading.value = false;
		} catch (e) {
			errorMessage.value = 'Erreur lors du chargement des entêtes: $e';
			isLoading.value = false;
		}
	}

	void initializeTableFromSchema(TemplateFichecontrole template) {
		if (template.schema == null) {
			createDefaultSchema();
			return;
		}
		try {
			Map<String, dynamic> schema = Map<String, dynamic>.from(template.schema!);
			if (schema.isEmpty || (!schema.containsKey('elements') && !schema.containsKey('tables'))) {
				schema = SchemaUtils.createTestSchema();
			}
			if (!schema.containsKey('tables')) {
				SchemaUtils.convertLegacySchema(schema);
			}
			schemaData.value = schema;
		} catch (e) {
			createDefaultSchema();
		}
	}

	void createDefaultSchema() {
		schemaData.value = {
			'tables': SchemaUtils.createDefaultTable()
		};
	}

	void onEnteteValueChanged(int enteteId, String value) {
		enteteValues[enteteId] = value;
	}

	void onCellChanged(int tableIndex, int rowIndex, int colIndex, String value) {
		saveTimer?.cancel();
		String cellKey = 'table_${tableIndex}_row_${rowIndex}_col_$colIndex';
		pendingChanges[cellKey] = value;
		saveTimer = Timer(const Duration(milliseconds: 500), () {
			savePendingChanges();
		});
	}

	void savePendingChanges() {
		// ...existing logic from view...
		pendingChanges.clear();
	}

	void onAnomalieAdded(Map<String, dynamic> anomalieData) {
		anomalies.add(anomalieData);
	}

	void nextStep() {
		if (currentStep.value < 1) {
			currentStep.value++;
		}
	}

	void previousStep() {
		if (currentStep.value > 0) {
			currentStep.value--;
		}
	}

	void resetFormAfterSuccess() {
		schemaData.clear();
		pendingChanges.clear();
		saveTimer?.cancel();
		enteteValues.clear();
		photoObligatoire.value = null;
		anomalies.clear();
		currentStep.value = 0;
		loadEntetes();
	}

	// Add other methods as needed for navigation, error/success handling, etc.
}
