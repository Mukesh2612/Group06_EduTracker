import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../admin/admin_dashboard.dart';
import '../student/student_dashboard.dart';
import '../Fa/fa_dashboard.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final pass = TextEditingController();
  bool showPass = false;

  // Theme colors
  static const bg = Color(0xFFE8E9EB);
  static const light = Color(0xFFCCCDC6);
  static const dark = Color(0xFF746D69);
  static const black = Color(0xFF262626);

  Future<void> loginUser() async {
    final e = email.text.trim();
    final p = pass.text.trim();

    final url = Uri.parse("http://192.168.1.11:8080/auth/login");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": e,
          "password": p,
        }),
      );

      if (response.statusCode == 200) {
        final result = response.body;

        if (result.contains("STUDENT")) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const StudentDashboard()),
          );
        }
        else if (result.contains("ADMIN")) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AdminDashboard()),
          );
        }
        else if (result.contains("FA")) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const FADashboard()),
          );
        }
        else {
          msg("Invalid credentials");
        }
      } else {
        msg("Login failed");
      }
    } catch (e) {
      print("LOGIN ERROR: $e");
      msg("Cannot connect to server");
    }
  }


  void msg(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  InputDecoration field(String hint, {Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      suffixIcon: suffix,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: light),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: black, width: 1.5),
      ),
    );
  }

  ButtonStyle primaryBtn() {
    return ElevatedButton.styleFrom(
      backgroundColor: black,
      foregroundColor: bg,
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }

  @override
  void dispose() {
    email.dispose();
    pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                // LOGO
                Center(
                  child: Image.asset(
                    "assets/design.png",
                    height: 160,
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(height: 25),

                const Center(
                  child: Text(
                    "Login to continue",
                    style: TextStyle(
                      color: dark,
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Email
                TextField(
                  controller: email,
                  decoration: field("Email"),
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 14),

                // Password
                TextField(
                  controller: pass,
                  obscureText: !showPass,
                  decoration: field(
                    "Password",
                    suffix: IconButton(
                      onPressed: () => setState(() => showPass = !showPass),
                      icon: Icon(
                        showPass
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: dark,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ForgotPasswordPage(),
                        ),
                      );
                    },
                    child: const Text(
                      "Forgot Password?",
                      style: TextStyle(color: black),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Login button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: primaryBtn(),
                    onPressed: () {
                      if (email.text.isEmpty || pass.text.isEmpty) {
                        msg("Enter email and password");
                        return;
                      }

                      loginUser();
                    },
                    child: const Text(
                      "Login",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Change password
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ChangePasswordPage(),
                        ),
                      );
                    },
                    child: const Text(
                      "Change Password",
                      style: TextStyle(
                        color: black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ======================================================
// Forgot Password (UI only)
// ======================================================
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final email = TextEditingController();

  static const bg = Color(0xFFE8E9EB);
  static const light = Color(0xFFCCCDC6);
  static const dark = Color(0xFF746D69);
  static const black = Color(0xFF262626);

  void msg(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  InputDecoration field(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: light),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: black, width: 1.5),
      ),
    );
  }

  ButtonStyle primaryBtn() {
    return ElevatedButton.styleFrom(
      backgroundColor: black,
      foregroundColor: bg,
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }

  @override
  void dispose() {
    email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        iconTheme: const IconThemeData(color: black),
        title: const Text(
          "Forgot Password",
          style: TextStyle(color: black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Enter your email to reset password",
              style: TextStyle(
                color: dark,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: email,
              decoration: field("Email"),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: primaryBtn(),
                onPressed: () {
                  if (email.text.trim().isEmpty) {
                    msg("Enter your email");
                    return;
                  }
                  msg("Reset link sent (UI only)");
                },
                child: const Text("Send Reset Link"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================================================
// Change Password (UI only)
// ======================================================
class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final email = TextEditingController();
  final oldPass = TextEditingController();
  final newPass = TextEditingController();
  final confirmPass = TextEditingController();

  bool showOld = false;
  bool showNew = false;
  bool showConfirm = false;

  static const bg = Color(0xFFE8E9EB);
  static const light = Color(0xFFCCCDC6);
  static const dark = Color(0xFF746D69);
  static const black = Color(0xFF262626);

  void msg(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  InputDecoration field(String hint, {Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      suffixIcon: suffix,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: light),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: black, width: 1.5),
      ),
    );
  }

  ButtonStyle primaryBtn() {
    return ElevatedButton.styleFrom(
      backgroundColor: black,
      foregroundColor: bg,
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }

  @override
  void dispose() {
    email.dispose();
    oldPass.dispose();
    newPass.dispose();
    confirmPass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        iconTheme: const IconThemeData(color: black),
        title: const Text(
          "Change Password",
          style: TextStyle(color: black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            TextField(
              controller: email,
              keyboardType: TextInputType.emailAddress,
              decoration: field("Email"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: oldPass,
              obscureText: !showOld,
              decoration: field(
                "Old Password",
                suffix: IconButton(
                  onPressed: () => setState(() => showOld = !showOld),
                  icon: Icon(
                    showOld
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: dark,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newPass,
              obscureText: !showNew,
              decoration: field(
                "New Password",
                suffix: IconButton(
                  onPressed: () => setState(() => showNew = !showNew),
                  icon: Icon(
                    showNew
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: dark,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmPass,
              obscureText: !showConfirm,
              decoration: field(
                "Confirm Password",
                suffix: IconButton(
                  onPressed: () => setState(() => showConfirm = !showConfirm),
                  icon: Icon(
                    showConfirm
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: dark,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: primaryBtn(),
                onPressed: () {
                  if (email.text.trim().isEmpty ||
                      oldPass.text.trim().isEmpty ||
                      newPass.text.trim().isEmpty ||
                      confirmPass.text.trim().isEmpty) {
                    msg("Fill all fields");
                    return;
                  }

                  if (newPass.text.trim() != confirmPass.text.trim()) {
                    msg("Passwords not matching");
                    return;
                  }

                  msg("Password updated (UI only)");
                },
                child: const Text("Update Password"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
