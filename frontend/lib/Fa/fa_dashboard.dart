import 'package:flutter/material.dart';
import 'review_application_page.dart';
import '../Auth/login_page.dart';

class FADashboard extends StatefulWidget {
  const FADashboard({super.key});

  @override
  State<FADashboard> createState() => _FADashboardState();
}

class _FADashboardState extends State<FADashboard> {
  // Grayscale Palette (same as login/admin/student)
  static const bg = Color(0xFFE8E9EB);
  static const light = Color(0xFFCCCDC6);
  static const mid = Color(0xFFACADA8);
  static const dark = Color(0xFF746D69);
  static const black = Color(0xFF262626);

  // Goal
  int? targetPoints;
  final TextEditingController goalController = TextEditingController();

  final List<Map<String, String>> students = [
    {'name': 'Rahul Patel', 'roll': 'NIT2021', 'points': '20'},
    {'name': 'Mukesh', 'roll': 'NIT2022', 'points': '18'},
    {'name': 'Varshith', 'roll': 'NIT2023', 'points': '15'},
    {'name': 'Thanooj', 'roll': 'NIT2024', 'points': '22'},
    {'name': 'Pranathi', 'roll': 'NIT2024', 'points': '22'},
    {'name': 'Sneha Gupta', 'roll': 'NIT2024', 'points': '22'},
  ];

  @override
  void dispose() {
    goalController.dispose();
    super.dispose();
  }

  void msg(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  // ✅ REAL LOGOUT
  void logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: black,
              foregroundColor: bg,
            ),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const LoginPage(),
                ),
                    (route) => false,
              );
            },
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }

  void showSetGoalDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Set Target Points"),
        content: TextField(
          controller: goalController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: "Enter required points",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              goalController.clear();
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: black,
              foregroundColor: bg,
            ),
            onPressed: () {
              final val = int.tryParse(goalController.text.trim());

              if (val == null || val <= 0) {
                msg("Enter valid points");
                return;
              }

              setState(() => targetPoints = val);
              goalController.clear();
              Navigator.pop(context);

              msg("Target set to $val points (UI only)");
            },
            child: const Text("Set Goal"),
          ),
        ],
      ),
    );
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
          "FA Dashboard",
          style: TextStyle(
            color: black,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout_rounded),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // FA PROFILE CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: light),
              ),
              child: Row(
                children: [
                  Container(
                    height: 52,
                    width: 52,
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: light),
                    ),
                    child: const Icon(Icons.person, color: black),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Dr. A. Dhiraj",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: black,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Faculty Advisor • CSE",
                          style: TextStyle(
                            color: dark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: black,
                        foregroundColor: bg,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: showSetGoalDialog,
                      child: const Text(
                        "Set Goal",
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),
            Expanded(
              child: ListView.builder(
                itemCount: students.length,
                itemBuilder: (context, index) {
                  final s = students[index];
                  return ListTile(
                    title: Text(s['name']!),
                    subtitle: Text("Roll: ${s['roll']}"),
                    trailing: Text("${s['points']} pts"),
                  );
                },
              ),
            ),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: black,
                  foregroundColor: bg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.pending_actions_rounded),
                label: const Text(
                  "View Pending Requests",
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ReviewApplicationPage(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
