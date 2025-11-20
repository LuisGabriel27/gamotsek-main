import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'package:google_fonts/google_fonts.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false;

  void _registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await DatabaseHelper.instance.addUser(
        _fullNameController.text.trim(),
        _usernameController.text.trim(),
        _passwordController.text.trim(),
        'user',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ User registered successfully!')),
      );

      _fullNameController.clear();
      _usernameController.clear();
      _passwordController.clear();

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('⚠️ Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 80),
                // Logo and Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'GAMOT',
                      style: GoogleFonts.poppins(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFE53935),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'SEK',
                              style: GoogleFonts.poppins(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '✓',
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFE53935),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 60),

                // Full Name Field
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey[300]!,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextFormField(
                    controller: _fullNameController,
                    decoration: InputDecoration(
                      hintText: 'Full Name',
                      hintStyle: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                      prefixIcon: Icon(
                        Icons.person_outline,
                        color: const Color(0xFFE53935),
                        size: 24,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 0,
                      ),
                    ),
                    style: const TextStyle(fontSize: 16),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter your full name' : null,
                  ),
                ),
                const SizedBox(height: 16),

                // Email Address Field
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey[300]!,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      hintText: 'Email Address',
                      hintStyle: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                      prefixIcon: Icon(
                        Icons.mail_outline,
                        color: const Color(0xFFE53935),
                        size: 24,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 0,
                      ),
                    ),
                    style: const TextStyle(fontSize: 16),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter a username' : null,
                  ),
                ),
                const SizedBox(height: 16),

                // Password Field
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey[300]!,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      hintStyle: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        color: const Color(0xFFE53935),
                        size: 24,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_off_outlined,
                          color: Colors.grey[400],
                          size: 24,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 0,
                      ),
                    ),
                    style: const TextStyle(fontSize: 16),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter a password' : null,
                  ),
                ),
                const SizedBox(height: 32),

                // Register Button
                SizedBox(
                  width: double.infinity,
                  child: _isLoading
                      ? const SizedBox(
                          height: 56,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFFE53935),
                            ),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: _registerUser,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE53935),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'REGISTER',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 32),

                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[700],
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Login',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFE53935),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
