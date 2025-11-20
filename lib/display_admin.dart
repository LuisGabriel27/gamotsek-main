import 'package:flutter/material.dart';
import 'database_helper.dart';

class DisplayAdminsPage extends StatefulWidget {
  const DisplayAdminsPage({super.key});

  @override
  State<DisplayAdminsPage> createState() => _DisplayAdminsPageState();
}

class _DisplayAdminsPageState extends State<DisplayAdminsPage> {
  List<Map<String, dynamic>> _admins = [];

  @override
  void initState() {
    super.initState();
    _fetchAdmins();
  }

  Future<void> _fetchAdmins() async {
    final db = await DatabaseHelper.instance.database;
    final result =
        await db.query('users', where: 'role = ?', whereArgs: ['admin']);
    setState(() {
      _admins = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin List'),
        backgroundColor: Colors.teal,
      ),
      body: _admins.isEmpty
          ? const Center(child: Text('No admins found.'))
          : ListView.builder(
              itemCount: _admins.length,
              itemBuilder: (context, index) {
                final admin = _admins[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  child: ListTile(
                    leading: const Icon(Icons.person, color: Colors.teal),
                    // ✅ Show full name if exists, fallback to username
                    title: Text(admin['full_name'] ?? admin['username']),
                    subtitle: Text('Role: ${admin['role']}'),
                  ),
                );
              },
            ),
    );
  }
}
