import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'activity_history_page.dart';
import '../auth/login_page.dart';
import '../config/api.dart';
import 'apply_activity_page.dart';
import 'generate_report_screen.dart';

class StudentDashboard extends StatefulWidget {
  final String email;

  const StudentDashboard({
    super.key,
    required this.email,
  });

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  static const bg = Color(0xFFE8E9EB);
  static const light = Color(0xFFCCCDC6);
  static const mid = Color(0xFFACADA8);
  static const dark = Color(0xFF746D69);
  static const black = Color(0xFF262626);

  String name = "";
  String rollNo = "";
  String email = "";
  String dept = "";
  String faName = "";
  String faEmail = "";
  int points = 0;
  // ✅ FIX: Store studentId so it can be passed to ApplyActivityScreen
  int studentId = 0;

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  void toast(String t) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(t)));
  }

  Future<void> sendEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: faEmail,
      query: Uri.encodeFull(
        'subject=Query from Student&body=Hello $faName,\n\nI have a query regarding activities.\n\nStudent Name: $name\nRoll No: $rollNo\nDepartment: $dept\nEmail: $email\n',
      ),
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      toast("Could not open email app");
    }
  }

  Future<void> loadProfile() async {
    try {
      final response = await http.get(
        Uri.parse("$BASE_URL/auth/student/profile/${widget.email}"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          // ✅ FIX: Store the student's real id from backend
          studentId = data["id"] ?? 0;
          name = data["name"] ?? "";
          rollNo = data["rollNo"] ?? "";
          email = data["email"] ?? "";
          dept = data["dept"] ?? "";
          faName = data["faName"] ?? "";
          faEmail = data["faEmail"] ?? "";
          // points comes from users.points column — updated by SubmissionService.approve()
          points = data["points"] ?? 0;
          loading = false;
        });
      } else {
        toast("Server error");
      }
    } catch (e) {
      toast("Backend connection failed");
    }
  }

  void logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginPage()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: bg,
      key: const Key("studentDashboard"),
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        title: const Text(
          "Student Dashboard",

          style: TextStyle(color: black, fontWeight: FontWeight.w900),
        ),
        iconTheme: const IconThemeData(color: black),
        actions: [
          // ✅ FIX: Refresh button so student can pull latest points after FA approves
          IconButton(
            onPressed: loadProfile,
            icon: const Icon(Icons.refresh_rounded),
          ),
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // PROFILE CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: light),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Profile",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    infoRow("Name", name),
                    infoRow("Roll No", rollNo),
                    infoRow("Email", email),
                    infoRow("Department", dept),
                    const Divider(height: 26),
                    infoRow("FA Name", faName),
                    infoRow("FA Email", faEmail),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // TOTAL POINTS CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: light),
                ),
                child: Row(
                  children: [
                    Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: light),
                      ),
                      child: const Icon(Icons.star, color: black),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        "Total Points",
                        style: TextStyle(
                          fontSize: 14,
                          color: dark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      "$points",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: black,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // APPLY DOCUMENT
              actionButton(
                "Apply New Document",
                Icons.upload_file,
                    () async {
                  // ✅ FIX: Pass real studentId; await return so points refresh after coming back
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ApplyActivityScreen(studentId: studentId),
                    ),
                  );
                  // Reload profile in case FA approved something while student was away
                  loadProfile();
                },
              ),

              const SizedBox(height: 12),

              actionButton(
                "View Activity History",
                Icons.history,
                    () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ActivityHistoryPage(studentId: studentId),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              actionButton("Send Query to FA", Icons.mail, sendEmail),

              const SizedBox(height: 12),

              actionButton(
                "Generate Reports",
                Icons.bar_chart,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GenerateReportScreen(studentId: studentId),
                        ),
                      );
                },
              ),

              const SizedBox(height: 20),

              Text(
                "EduTracker • Student Module",
                style: TextStyle(
                  color: mid,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                color: dark,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: black,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget actionButton(
      String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: light),
        ),
        child: Row(
          children: [
            Container(
              height: 46,
              width: 46,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: light),
              ),
              child: Icon(icon, color: black),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: black,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: dark),
          ],
        ),
      ),
    );
  }
}