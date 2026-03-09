import 'package:flutter/material.dart';

class GenerateReportScreen extends StatefulWidget {
  const GenerateReportScreen({super.key});

  @override
  State<GenerateReportScreen> createState() => _GenerateReportScreenState();
}

class _GenerateReportScreenState extends State<GenerateReportScreen> {
  String? selectedSemester;

  final List<String> semesters = const [
    "Semester 1",
    "Semester 2",
    "Semester 3",
    "Semester 4",
    "Semester 5",
    "Semester 6",
    "Semester 7",
    "Semester 8",
  ];

  // Same palette as your app
  static const bg = Color(0xFFE8E9EB);
  static const light = Color(0xFFCCCDC6);
  static const mid = Color(0xFFACADA8);
  static const dark = Color(0xFF746D69);
  static const black = Color(0xFF262626);

  InputDecoration fieldStyle(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: dark, fontWeight: FontWeight.w700),
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

  void msg(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
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
          "Generate Report",
          style: TextStyle(
            color: black,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // =========================
            // CARD
            // =========================
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
                    "Select Semester",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: black,
                    ),
                  ),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    decoration: fieldStyle("Semester"),
                    value: selectedSemester,
                    items: semesters.map((sem) {
                      return DropdownMenuItem(
                        value: sem,
                        child: Text(sem),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => selectedSemester = value);
                    },
                  ),

                  const SizedBox(height: 16),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: light),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded, color: black),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            selectedSemester == null
                                ? "Choose a semester to generate your report."
                                : "Report will be generated for $selectedSemester.",
                            style: const TextStyle(
                              color: dark,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // =========================
            // DOWNLOAD BUTTON
            // =========================
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: primaryBtn(),
                icon: const Icon(Icons.download_rounded),
                label: const Text(
                  "Download Report",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                onPressed: selectedSemester == null
                    ? null
                    : () {
                  msg("Report for $selectedSemester downloaded (UI only)");
                },
              ),
            ),

            const SizedBox(height: 12),

            Text(
              "EduTracker • Reports Module",
              style: TextStyle(
                color: mid,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
