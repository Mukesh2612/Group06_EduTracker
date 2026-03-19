import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../auth/login_page.dart';
import 'apply_activity_page.dart';
import 'generate_report_screen.dart';



class StudentDashboard extends StatelessWidget {
  final Map user;

  const StudentDashboard({super.key, required this.user});

  static const bg = Color(0xFFE8E9EB);
  static const light = Color(0xFFCCCDC6);
  static const mid = Color(0xFFACADA8);
  static const dark = Color(0xFF746D69);
  static const black = Color(0xFF262626);

  Future<void> sendEmail(BuildContext context, String faEmail) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: faEmail,
      queryParameters: {
        "subject": "Query from Student",
        "body": "Hello Sir/Madam,\n\n",
      },
    );

    try {
      await launchUrl(emailUri, mode: LaunchMode.externalApplication);
    } catch (_) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Email app not found")));
    }
  }

  void logout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = user["name"] ?? "";
    final email = user["email"] ?? "";
    final dept = user["department"] ?? "";
    final faEmail = user["faEmail"] ?? "";
    final totalPoints = user["totalPoints"]?.toString() ?? "0";
    final studentId = user["id"];

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        title: const Text(
          "Student Dashboard",
          style: TextStyle(color: black, fontWeight: FontWeight.w900),
        ),
        iconTheme: const IconThemeData(color: black),
        actions: [
          IconButton(
            onPressed: () => logout(context),
            icon: const Icon(Icons.logout_rounded),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// PROFILE
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: light),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Profile",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: black)),
                  const SizedBox(height: 10),
                  _InfoRow(label: "Name", value: name),
                  _InfoRow(label: "Email", value: email),
                  _InfoRow(label: "Department", value: dept),
                  const Divider(),
                  _InfoRow(label: "FA Email", value: faEmail),
                ],
              ),
            ),

            const SizedBox(height: 14),

            /// TOTAL POINTS
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: light),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star_rounded, color: black),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text("Total Points",
                        style: TextStyle(
                            color: dark, fontWeight: FontWeight.w700)),
                  ),
                  Text(totalPoints,
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: black))
                ],
              ),
            ),

            const SizedBox(height: 18),

            /// APPLY ACTIVITY
            _ActionButton(
              title: "Apply New Document",
              icon: Icons.upload_file_rounded,
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ApplyActivityScreen(
                      studentId: studentId,
                    ),
                  ),
                );

                if (result == true) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Application sent to FA")),
                  );
                }
              },
            ),

            const SizedBox(height: 12),

            /// HISTORY
            _ActionButton(
              title: "View Activity History",
              icon: Icons.history_rounded,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ActivityHistoryScreen(studentId: studentId),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            /// MAIL FA
            _ActionButton(
              title: "Send Query to FA",
              icon: Icons.mail_rounded,
              onTap: () => sendEmail(context, faEmail),
            ),

            const SizedBox(height: 12),

            /// REPORT
            _ActionButton(
              title: "Generate Reports",
              icon: Icons.bar_chart_rounded,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const GenerateReportScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// ============================
/// Activity History
/// ============================

class ActivityHistoryScreen extends StatefulWidget {
  final int studentId;

  const ActivityHistoryScreen({super.key, required this.studentId});

  @override
  State<ActivityHistoryScreen> createState() => _ActivityHistoryScreenState();
}

class _ActivityHistoryScreenState extends State<ActivityHistoryScreen> {
  static const bg = Color(0xFFE8E9EB);
  static const light = Color(0xFFCCCDC6);
  static const dark = Color(0xFF746D69);
  static const black = Color(0xFF262626);

  List activities = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadActivities();
  }

  Future<void> loadActivities() async {
    try {
      final res = await http.get(Uri.parse(
          "http://localhost:8080/api/submissions/student/${widget.studentId}"));

      if (res.statusCode == 200) {
        setState(() {
          activities = jsonDecode(res.body) ?? [];
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        loading = false;
      });
    }
  }

  Color statusColor(String status) {
    if (status == "APPROVED") return Colors.green;
    if (status == "REJECTED") return Colors.red;
    return Colors.orange;
  }

  void openFile(String filename) async {
    final url = Uri.parse("http://localhost:8080/uploads/$filename");
    await launchUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        iconTheme: const IconThemeData(color: black),
        title: const Text("Activity History",
            style: TextStyle(color: black, fontWeight: FontWeight.w900)),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : activities.isEmpty
              ? const Center(
                  child: Text("No activities submitted yet",
                      style:
                          TextStyle(color: dark, fontWeight: FontWeight.w700)),
                )
              : RefreshIndicator(
                  onRefresh: loadActivities,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: activities.length,
                    itemBuilder: (context, i) {
                      final a = activities[i];

                      final title = a["title"] ?? "-";
                      final category = a["category"] ?? "-";
                      final status = a["status"] ?? "PENDING";
                      final remarks = a["remarks"] ?? "";
                      final proof = a["proofFile"] ?? "";
                      final points = a["points"]?.toString() ?? "";

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: light),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(title,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w900,
                                              fontSize: 16)),
                                      const SizedBox(height: 4),
                                      Text(category,
                                          style: const TextStyle(
                                              color: dark,
                                              fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color:
                                        statusColor(status).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Text(status,
                                      style: TextStyle(
                                          color: statusColor(status),
                                          fontWeight: FontWeight.w800)),
                                )
                              ],
                            ),
                            if (points != "")
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text("$points Points",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700)),
                              ),
                            if (remarks != "")
                              Container(
                                margin: const EdgeInsets.only(top: 10),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.info_outline,
                                        color: Colors.red),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(remarks,
                                          style: const TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.w700)),
                                    )
                                  ],
                                ),
                              ),
                            if (proof != "")
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: GestureDetector(
                                  onTap: () => openFile(proof),
                                  child: const Text(
                                    "View Certificate",
                                    style: TextStyle(
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                              )
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

/// ============================
/// SMALL WIDGETS
/// ============================

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  static const dark = Color(0xFF746D69);
  static const black = Color(0xFF262626);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style:
                    const TextStyle(color: dark, fontWeight: FontWeight.w700)),
          ),
          Expanded(
            child: Text(value,
                style:
                    const TextStyle(color: black, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionButton(
      {required this.title, required this.icon, required this.onTap});

  static const light = Color(0xFFCCCDC6);
  static const black = Color(0xFF262626);

  @override
  Widget build(BuildContext context) {
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
            Icon(icon, color: black),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w900, color: black)),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16)
          ],
        ),
      ),
    );
  }
}
