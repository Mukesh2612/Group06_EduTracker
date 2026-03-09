import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../auth/login_page.dart';
import 'apply_activity_page.dart';
import 'generate_report_screen.dart';

/// ============================
/// Student Module (UI ONLY)
/// - StudentDashboard
/// - ActivityHistoryScreen
/// ============================

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  // Grayscale Palette (same as your login/admin)
  static const bg = Color(0xFFE8E9EB);
  static const light = Color(0xFFCCCDC6);
  static const mid = Color(0xFFACADA8);
  static const dark = Color(0xFF746D69);
  static const black = Color(0xFF262626);

  /// ✅ Send Query Mail (opens mail app)
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
      final ok = await launchUrl(
        emailUri,
        mode: LaunchMode.externalApplication,
      );

      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Email app not found")),
        );
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email app not found")),
      );
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
    // Dummy UI data
    const name = "Varshith";
    const email = "varshith@gmail.com";
    const dept = "CSE";
    const faName = "Dr. Rao";
    const faEmail = "rao@gmail.com";
    const totalPoints = 120;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        title: const Text(
          "Student Dashboard",
          style: TextStyle(
            color: black,
            fontWeight: FontWeight.w900,
          ),
        ),
        iconTheme: const IconThemeData(color: black),
        actions: [
          IconButton(
            onPressed: () => logout(context),
            icon: const Icon(Icons.logout_rounded),
          ),
          const SizedBox(width: 6),
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
                    _InfoRow(label: "Name", value: name),
                    _InfoRow(label: "Email", value: email),
                    _InfoRow(label: "Department", value: dept),
                    const Divider(height: 26),
                    _InfoRow(label: "FA Name", value: faName),
                    _InfoRow(label: "FA Email", value: faEmail),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // TOTAL POINTS
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
                      child: const Icon(Icons.star_rounded, color: black),
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
                      "$totalPoints",
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

              // ACTION BUTTONS
              _ActionButton(
                title: "Apply New Document",
                icon: Icons.upload_file_rounded,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ApplyActivityScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),

              _ActionButton(
                title: "View Activity History",
                icon: Icons.history_rounded,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ActivityHistoryScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),

              // SEND QUERY TO FA (MAIL)
              _ActionButton(
                title: "Send Query to FA",
                icon: Icons.mail_rounded,
                onTap: () => sendEmail(context, faEmail),
              ),
              const SizedBox(height: 12),

              // GENERATE REPORTS
              _ActionButton(
                title: "Generate Reports",
                icon: Icons.bar_chart_rounded,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const GenerateReportScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 18),

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
}

/// ==========================================
/// Activity Model
/// ==========================================
class Activity {
  final String title;
  final String category;
  final String status;
  final int points;
  final String? remarks;

  Activity({
    required this.title,
    required this.category,
    required this.status,
    required this.points,
    this.remarks,
  });
}

/// ==========================================
/// Activity History Screen (UI ONLY)
/// ==========================================
class ActivityHistoryScreen extends StatelessWidget {
  const ActivityHistoryScreen({super.key});

  // Grayscale Palette
  static const bg = Color(0xFFE8E9EB);
  static const light = Color(0xFFCCCDC6);
  static const dark = Color(0xFF746D69);
  static const black = Color(0xFF262626);

  @override
  Widget build(BuildContext context) {
    final List<Activity> activities = [
      Activity(
        title: "Paper Presentation",
        category: "Technical",
        status: "Approved",
        points: 10,
      ),
      Activity(
        title: "Hackathon",
        category: "Competition",
        status: "Rejected",
        points: 20,
        remarks: "Insufficient proof uploaded",
      ),
      Activity(
        title: "Sports Meet",
        category: "Sports",
        status: "Pending",
        points: 15,
      ),
    ];

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        iconTheme: const IconThemeData(color: black),
        title: const Text(
          "Activity History",
          style: TextStyle(color: black, fontWeight: FontWeight.w900),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: activities.length,
          itemBuilder: (context, index) {
            final a = activities[index];

            final statusColor = a.status == "Approved"
                ? Colors.green
                : a.status == "Rejected"
                ? Colors.red
                : Colors.orange;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: light),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    a.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Category: ${a.category}",
                    style: const TextStyle(
                      color: dark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      // Status chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          a.status.toUpperCase(),
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Points chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F2F2),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          "${a.points} pts",
                          style: const TextStyle(
                            color: black,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (a.status == "Rejected" && a.remarks != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      "Remark: ${a.remarks}",
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// ==========================================
/// Small Widgets (clean code)
/// ==========================================
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
}

class _ActionButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionButton({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  static const light = Color(0xFFCCCDC6);
  static const bg = Color(0xFFE8E9EB);
  static const black = Color(0xFF262626);
  static const dark = Color(0xFF746D69);

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
            const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: dark),
          ],
        ),
      ),
    );
  }
}
