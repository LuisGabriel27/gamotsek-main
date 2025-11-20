import 'package:flutter/material.dart';
import 'medicine.dart';
import 'database_helper.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class MedicineDetailsPage extends StatefulWidget {
  final Medicine medicine;

  const MedicineDetailsPage({super.key, required this.medicine});

  @override
  State<MedicineDetailsPage> createState() => _MedicineDetailsPageState();
}

class _MedicineDetailsPageState extends State<MedicineDetailsPage> {
  String _selectedLanguage = 'English';

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _dosageController;
  late TextEditingController _usageController;
  late TextEditingController _sideEffectsController;
  late TextEditingController _precautionsController;

  late TextEditingController _nameTagalogController;
  late TextEditingController _dosageTagalogController;
  late TextEditingController _usageTagalogController;
  late TextEditingController _sideEffectsTagalogController;
  late TextEditingController _precautionsTagalogController;

  late OnDeviceTranslator _translator;
  bool _isTranslating = false;

  @override
  void initState() {
    super.initState();

// Initialize the on-device translator from English to Tagalog
    _translator = OnDeviceTranslator(
      sourceLanguage: TranslateLanguage.english,
      targetLanguage: TranslateLanguage.tagalog,
    );

    _nameController = TextEditingController(text: widget.medicine.name);
    _dosageController = TextEditingController(text: widget.medicine.dosage);
    _usageController = TextEditingController(text: widget.medicine.usage);
    _sideEffectsController =
        TextEditingController(text: widget.medicine.sideEffects);
    _precautionsController =
        TextEditingController(text: widget.medicine.precautions);

    _nameTagalogController =
        TextEditingController(text: widget.medicine.nameTagalog ?? '');
    _dosageTagalogController =
        TextEditingController(text: widget.medicine.dosageTagalog ?? '');
    _usageTagalogController =
        TextEditingController(text: widget.medicine.usageTagalog ?? '');
    _sideEffectsTagalogController =
        TextEditingController(text: widget.medicine.sideEffectsTagalog ?? '');
    _precautionsTagalogController =
        TextEditingController(text: widget.medicine.precautionsTagalog ?? '');
  }

  @override
  void dispose() {
    _translator.close();
    _nameController.dispose();
    _dosageController.dispose();
    _usageController.dispose();
    _sideEffectsController.dispose();
    _precautionsController.dispose();
    _nameTagalogController.dispose();
    _dosageTagalogController.dispose();
    _usageTagalogController.dispose();
    _sideEffectsTagalogController.dispose();
    _precautionsTagalogController.dispose();
    super.dispose();
  }

// Update the medicine record in database (either English or Tagalog)
  Future<void> _updateMedicine({required bool isTagalog}) async {
    final updatedMedicine = Medicine(
      id: widget.medicine.id,
      name: _nameController.text,
      dosage: _dosageController.text,
      usage: _usageController.text,
      sideEffects: _sideEffectsController.text,
      precautions: _precautionsController.text,
      nameTagalog: _nameTagalogController.text,
      dosageTagalog: _dosageTagalogController.text,
      usageTagalog: _usageTagalogController.text,
      sideEffectsTagalog: _sideEffectsTagalogController.text,
      precautionsTagalog: _precautionsTagalogController.text,
    );

// Save updated medicine to database
    await DatabaseHelper.instance.updateMedicine(updatedMedicine);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            '${isTagalog ? "Tagalog" : "English"} medicine updated successfully!'),
      ),
    );
  }

// Delete the medicine record from database
  Future<void> _deleteMedicine() async {
    await DatabaseHelper.instance.deleteMedicine(widget.medicine.id!);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Medicine deleted successfully!')),
    );
    Navigator.pop(context, true);
  }

 // Automatically translate English fields to Tagalog using on-device translator
  Future<void> _autoTranslateToTagalog() async {
    setState(() => _isTranslating = true);

    try {
      _nameTagalogController.text =
          await _translator.translateText(_nameController.text);
      _dosageTagalogController.text =
          await _translator.translateText(_dosageController.text);
      _usageTagalogController.text =
          await _translator.translateText(_usageController.text);
      _sideEffectsTagalogController.text =
          await _translator.translateText(_sideEffectsController.text);
      _precautionsTagalogController.text =
          await _translator.translateText(_precautionsController.text);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Translation completed successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Translation failed: $e')));
    }

    setState(() => _isTranslating = false);
  }

  @override
  Widget build(BuildContext context) {
    final isTagalog = _selectedLanguage == 'Tagalog';
    final controllers = isTagalog
        ? [
            _nameTagalogController,
            _dosageTagalogController,
            _usageTagalogController,
            _sideEffectsTagalogController,
            _precautionsTagalogController,
          ]
        : [
            _nameController,
            _dosageController,
            _usageController,
            _sideEffectsController,
            _precautionsController,
          ];

    final labels = [
      'Medicine Name',
      'Dosage',
      'Usage',
      'Side Effects',
      'Precautions'
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isTagalog
              ? (_nameTagalogController.text.isEmpty
                  ? _nameController.text
                  : _nameTagalogController.text)
              : _nameController.text,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            DropdownButton<String>(
              value: _selectedLanguage,
              items: const [
                DropdownMenuItem(value: 'English', child: Text('English')),
                DropdownMenuItem(value: 'Tagalog', child: Text('Tagalog')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedLanguage = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // Box-style fields
            ...List.generate(controllers.length, (i) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: TextField(
                  controller: controllers[i],
                  decoration: InputDecoration(
                    labelText: '${labels[i]} (${_selectedLanguage})',
                    border: const OutlineInputBorder(),
                  ),
                  readOnly: i == 0 && isTagalog, // prevent editing name in Tagalog
                        maxLines: (i == 0)
                            ? 1 // Name
                            : (i == 1)
                                ? 3 // Dosage
                                : 3, // Usage, Side Effects, Precautions
                        minLines: (i == 0)
                            ? 1
                            : (i == 1)
                                ? 2
                                : 3,
                ),
              );
            }),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isTranslating ? null : _autoTranslateToTagalog,
                    child: const Icon(Icons.translate),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _updateMedicine(isTagalog: isTagalog),
                    icon: const Icon(Icons.save),
                    label: const Text('Save'),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _deleteMedicine,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Icon(Icons.delete),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
