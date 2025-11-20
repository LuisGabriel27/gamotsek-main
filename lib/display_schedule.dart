import 'package:flutter/material.dart';
import 'database_helper.dart';

class DisplaySchedulePage extends StatefulWidget {
  const DisplaySchedulePage({super.key});

  @override
  State<DisplaySchedulePage> createState() => _DisplaySchedulePageState();
}

class _DisplaySchedulePageState extends State<DisplaySchedulePage> {
  List<Map<String, dynamic>> schedules = [];

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    final data = await DatabaseHelper.instance.getSchedules();
    setState(() {
      schedules = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Medicine Schedules"),
        backgroundColor: const Color(0xFFE53935),
      ),
      body: schedules.isEmpty
          ? const Center(child: Text("No schedules yet."))
          : ListView.builder(
              itemCount: schedules.length,
              itemBuilder: (context, index) {
                final schedule = schedules[index];
                final times = schedule['scheduleTimes'].split('|');

                return Card(
                  margin: const EdgeInsets.all(10),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              schedule['medicineName'],
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                // Confirm deletion
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text("Delete Schedule"),
                                    content: const Text(
                                        "Are you sure you want to delete this schedule?"),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: const Text("Cancel"),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        child: const Text("Delete"),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  await DatabaseHelper.instance
                                      .deleteSchedule(schedule['id']);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Schedule deleted")),
                                  );
                                  _loadSchedules(); // refresh the list
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text("Dosage: ${schedule['dosage']}"),
                        const SizedBox(height: 8),
                        const Text("Schedule:"),
                        const SizedBox(height: 5),
                        ...times.map(
                          (time) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              "${time.trim()} - ${schedule['medicineName']}",
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
