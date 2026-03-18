import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../admin/admin_dashboard.dart';
import '../student/student_dashboard.dart';
import '../Fa/fa_dashboard.dart';
import '../config/api.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final pass = TextEditingController();
  bool showPass = false;
  bool isLoading = false;

  static const bg = Color(0xFFE8E9EB);
  static const light = Color(0xFFCCCDC6);
  static const dark = Color(0xFF746D69);
  static const black = Color(0xFF262626);

  /// ================= LOGIN =================
  Future<void> loginUser() async {
    final e = email.text.trim();
    final p = pass.text.trim();

    final url = Uri.parse("$BASE_URL/auth/login");

    setState(() => isLoading = true);

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
        final data = jsonDecode(response.body);

        final role = data["role"];
        final firstLogin = data["firstLogin"] ?? false;

        /// 🚨 FIRST LOGIN
        if (firstLogin == true) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ChangePasswordPage(prefilledEmail: e),
            ),
          );
          return;
        }

        /// STUDENT
        if (role == "STUDENT") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => StudentDashboard(email: data["email"]),
            ),
          );
        }

        /// ADMIN
        else if (role == "ADMIN") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const AdminDashboard(),
            ),
          );
        }

        /// FA
        else if (role == "FA") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => FADashboard(user: data),
            ),
          );
        } else {
          msg("Invalid role");
        }
      } else {
        msg("Invalid email or password");
      }
    } catch (e) {
      print("LOGIN ERROR: $e");
      msg("Cannot connect to server");
    }

    setState(() => isLoading = false);
  }

  void msg(String text) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(text)));
  }

  InputDecoration field(String hint, {Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      suffixIcon: suffix,
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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

                /// LOGO
                Center(
                  child: Image.asset(
                    "assets/design.png",
                    height: 160,
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

                /// EMAIL
                TextField(
                  controller: email,
                  decoration: field("Email"),
                ),

                const SizedBox(height: 14),

                /// PASSWORD
                TextField(
                  controller: pass,
                  obscureText: !showPass,
                  decoration: field(
                    "Password",
                    suffix: IconButton(
                      onPressed: () =>
                          setState(() => showPass = !showPass),
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

                /// FORGOT PASSWORD
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

                /// LOGIN BUTTON
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: primaryBtn(),
                    onPressed: isLoading ? null : loginUser,
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Login"),
                  ),
                ),

                const SizedBox(height: 12),

                /// CHANGE PASSWORD
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

/// ======================================================
/// FORGOT PASSWORD (UI ONLY)
/// ======================================================
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() =>
      _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final email = TextEditingController();

  static const bg = Color(0xFFE8E9EB);
  static const light = Color(0xFFCCCDC6);
  static const dark = Color(0xFF746D69);
  static const black = Color(0xFF262626);

  void msg(String text) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(text)));
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
        title: const Text("Forgot Password",
            style: TextStyle(color: black)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            TextField(
              controller: email,
              decoration: InputDecoration(
                hintText: "Email",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => msg("Reset link sent (UI only)"),
              child: const Text("Send Reset Link"),
            )
          ],
        ),
      ),
    );
  }
}

/// ======================================================
/// CHANGE PASSWORD
/// ======================================================
class ChangePasswordPage extends StatefulWidget {
  final String? prefilledEmail;

  const ChangePasswordPage({super.key, this.prefilledEmail});

  @override
  State<ChangePasswordPage> createState() =>
      _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final email = TextEditingController();
  final oldPass = TextEditingController();
  final newPass = TextEditingController();
  final confirmPass = TextEditingController();

  static const bg = Color(0xFFE8E9EB);
  static const black = Color(0xFF262626);

  @override
  void initState() {
    super.initState();
    if (widget.prefilledEmail != null) {
      email.text = widget.prefilledEmail!;
    }
  }

  void msg(String text) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> changePassword() async {
    if (newPass.text != confirmPass.text) {
      msg("Passwords not matching");
      return;
    }

    try {
      final res = await http.post(
        Uri.parse("$BASE_URL/auth/change-password"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email.text,
          "oldPassword": oldPass.text,
          "newPassword": newPass.text,
        }),
      );

      if (res.statusCode == 200) {
        msg("Password updated");

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
              (route) => false,
        );
      } else {
        msg("Invalid old password");
      }
    } catch (e) {
      msg("Server error");
    }
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
        title:
        const Text("Change Password", style: TextStyle(color: black)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            TextField(controller: email, decoration: const InputDecoration(hintText: "Email")),
            const SizedBox(height: 12),
            TextField(controller: oldPass, obscureText: true, decoration: const InputDecoration(hintText: "Old Password")),
            const SizedBox(height: 12),
            TextField(controller: newPass, obscureText: true, decoration: const InputDecoration(hintText: "New Password")),
            const SizedBox(height: 12),
            TextField(controller: confirmPass, obscureText: true, decoration: const InputDecoration(hintText: "Confirm Password")),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: changePassword, child: const Text("Update Password")),
          ],
        ),
      ),
    );
  }
}
