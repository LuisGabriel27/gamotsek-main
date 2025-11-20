import 'package:flutter/material.dart';
import 'medicine.dart';
import 'database_helper.dart';
import 'medicine_details.dart';

class DisplayMedicinePage extends StatefulWidget {
  const DisplayMedicinePage({super.key});

  @override
  State<DisplayMedicinePage> createState() => _DisplayMedicinePageState();
}

class _DisplayMedicinePageState extends State<DisplayMedicinePage> {
  late Future<List<Medicine>> _medicinesFuture;

  @override
  void initState() {
    super.initState();
    _loadMedicines();
  }

  void _loadMedicines() {
    _medicinesFuture = DatabaseHelper.instance.getMedicines();
  }

  Future<void> _deleteMedicine(int id) async {
    await DatabaseHelper.instance.deleteMedicine(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Medicine deleted successfully!')),
    );
    setState(() {
      _loadMedicines();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Medicines')),
      body: FutureBuilder<List<Medicine>>(
        future: _medicinesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final medicines = snapshot.data ?? [];

          if (medicines.isEmpty) {
            return const Center(child: Text('No medicines added yet.'));
          }

          return ListView.builder(
            itemCount: medicines.length,
            itemBuilder: (context, index) {
              final med = medicines[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(med.name),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Delete button
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteMedicine(med.id!),
                      ),
                      const Icon(Icons.arrow_forward), // Navigate icon
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MedicineDetailsPage(medicine: med),
                      ),
                    ).then((value) {
                      // Refresh list after returning from details
                      setState(() {
                        _loadMedicines();
                      });
                    });
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _loadMedicines();
          });
        },
        child: const Icon(Icons.refresh),
        tooltip: 'Refresh',
      ),
    );
  }
}
