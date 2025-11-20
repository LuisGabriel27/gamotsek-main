import 'package:flutter/material.dart';
import 'login_page.dart'; 
//import 'admin_dashboard.dart'; 

void main() {
  runApp(const MedicineAdminApp());
}

class MedicineAdminApp extends StatelessWidget {
  const MedicineAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Medicine Scanner',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: const LoginPage(), 
    );
  }
}
