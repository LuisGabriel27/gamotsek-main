import 'package:flutter/material.dart';
import 'medicine.dart'; 
import 'database_helper.dart'; 

class AddMedicineForm extends StatefulWidget {
  const AddMedicineForm({super.key});

  @override
  State<AddMedicineForm> createState() => _AddMedicineFormState();
}

class _AddMedicineFormState extends State<AddMedicineForm> {
  final _formKey = GlobalKey<FormState>();

  String medicineName = '';
  String dosage = '';
  String usage = '';
  String sideEffects = '';
  String precautions = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Medicine')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Medicine Name',
                  border: OutlineInputBorder(),
                ),
                onSaved: (value) => medicineName = value ?? '',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter medicine name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Dosage',
                  border: OutlineInputBorder(),
                ),
                onSaved: (value) => dosage = value ?? '',
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Usage',
                  border: OutlineInputBorder(),
                ),
                onSaved: (value) => usage = value ?? '',
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Side Effects',
                  border: OutlineInputBorder(),
                ),
                onSaved: (value) => sideEffects = value ?? '',
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Precautions',
                  border: OutlineInputBorder(),
                ),
                onSaved: (value) => precautions = value ?? '',
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              // ✅ Updated ElevatedButton
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    // Create Medicine object
                    final medicine = Medicine(
                      name: medicineName,
                      dosage: dosage,
                      usage: usage,
                      sideEffects: sideEffects,
                      precautions: precautions,
                    );

                    // Save to database
                    await DatabaseHelper.instance.addMedicine(medicine);

                    // Clear form
                    _formKey.currentState!.reset();

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Medicine Added to Database!')),
                    );
                  }
                },
                child: const Text('Save Medicine'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
