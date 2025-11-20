import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'package:intl/intl.dart';

class CreateSchedulePage extends StatefulWidget {
  const CreateSchedulePage({super.key});

  @override
  State<CreateSchedulePage> createState() => _CreateSchedulePageState();
}

class _CreateSchedulePageState extends State<CreateSchedulePage> {
  final TextEditingController _medicineNameController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController();

  int _frequency = 1; // 1 to 5 times
  int _interval = 1; // in hours, 1 to 12
  DateTime? _startTime; // optional start time

  final List<int> _frequencyOptions = [1, 2, 3, 4, 5];
  final List<int> _intervalOptions = List.generate(12, (index) => index + 1);

  // Pick start time
  Future<void> _pickStartTime() async {
    final now = TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: now.hour, minute: now.minute),
    );

    if (picked != null) {
      final nowDate = DateTime.now();
      setState(() {
        _startTime = DateTime(nowDate.year, nowDate.month, nowDate.day, picked.hour, picked.minute);
      });
    }
  }

  // Generate schedule times based on start, frequency, interval
  List<String> generateScheduleTimes(DateTime startTime, int intervalHours, int dosesPerDay) {
    List<String> scheduleTimes = [];
    final formatter = DateFormat('EEE, MMM d, h:mm a'); // e.g., Mon, Nov 18, 7:00 AM

    for (int i = 0; i < dosesPerDay; i++) {
      DateTime doseTime = startTime.add(Duration(hours: i * intervalHours));
      scheduleTimes.add(formatter.format(doseTime));
    }

    return scheduleTimes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Medicine Schedule"),
        backgroundColor: const Color(0xFFE53935),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            // Medicine Name
            TextField(
              controller: _medicineNameController,
              decoration: const InputDecoration(
                labelText: "Medicine Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Dosage
            TextField(
              controller: _dosageController,
              decoration: const InputDecoration(
                labelText: "Dosage",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Frequency Dropdown (1 to 5 times)
            const Text(
              "Frequency (Times per day)",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              value: _frequency,
              items: _frequencyOptions
                  .map((value) => DropdownMenuItem(value: value, child: Text("$value")))
                  .toList(),
              onChanged: (value) => setState(() => _frequency = value!),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),

            // Interval Dropdown (every X hours)
            const Text(
              "Interval (Every X hours)",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              value: _interval,
              items: _intervalOptions
                  .map((value) => DropdownMenuItem(value: value, child: Text("$value hrs")))
                  .toList(),
              onChanged: (value) => setState(() => _interval = value!),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),

            // Start Time Picker
            Row(
              children: [
                const Text("Start Time: ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                TextButton(
                  onPressed: _pickStartTime,
                  child: Text(
                    _startTime != null
                        ? DateFormat('h:mm a').format(_startTime!)
                        : "Select Time",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Save Button
            ElevatedButton(
              onPressed: () async {
                if (_medicineNameController.text.isEmpty || _dosageController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please fill out all fields.")),
                  );
                  return;
                }

                final startTime = _startTime ?? DateTime.now();

                final scheduleTimes = generateScheduleTimes(startTime, _interval, _frequency);

                final schedule = {
                  'medicineName': _medicineNameController.text,
                  'dosage': _dosageController.text,
                  'frequency': _frequency,
                  'interval': _interval,
                  'scheduleTimes': scheduleTimes.join('|'), // separated by |
                };

                await DatabaseHelper.instance.insertSchedule(schedule);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Schedule Saved Successfully!")),
                );

                // Reset the form fields so user can add another schedule
                setState(() {
                  _medicineNameController.clear();
                  _dosageController.clear();
                  _frequency = 1;
                  _interval = 1;
                  _startTime = null;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53935),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                "Save Schedule",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
