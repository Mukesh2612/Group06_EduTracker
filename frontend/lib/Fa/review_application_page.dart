import 'package:flutter/material.dart';

class ReviewApplicationPage extends StatefulWidget {
  const ReviewApplicationPage({super.key});

  @override
  State<ReviewApplicationPage> createState() =>
      _ReviewApplicationPageState();
}

class _ReviewApplicationPageState
    extends State<ReviewApplicationPage> {
  // Grayscale Palette
  static const bg = Color(0xFFE8E9EB);
  static const light = Color(0xFFCCCDC6);
  static const dark = Color(0xFF746D69);
  static const black = Color(0xFF262626);

  final List<Map<String, String>> requests = [
    {
      'name': 'Rahul Patel',
      'category': 'Technical Event',
      'points': '10',
      'certificate': 'certificate_rahul.pdf',
    },
    {
      'name': 'Ananya Sharma',
      'category': 'Sports',
      'points': '5',
      'certificate': 'certificate_ananya.pdf',
    },
    {
      'name': 'Varshith',
      'category': 'Cultural Event',
      'points': '5',
      'certificate': 'certificate_varshith.pdf',
    },
  ];

  void handleAction(int index, bool isApproved) {
    final String studentName = requests[index]['name']!;

    setState(() {
      requests.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isApproved
              ? "✅ Request approved for $studentName (UI only)"
              : "❌ Request rejected for $studentName (UI only)",
        ),
        backgroundColor: isApproved ? Colors.green : Colors.red,
      ),
    );
  }

  InputDecoration remarkStyle() {
    return InputDecoration(
      hintText: "Enter remarks (optional)",
      filled: true,
      fillColor: Colors.white,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        iconTheme: const IconThemeData(color: black),
        title: const Text(
          "Review Applications",
          style: TextStyle(
            color: black,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: requests.isEmpty
          ? const Center(
        child: Text(
          "No Pending Requests",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: dark,
          ),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final r = requests[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: light),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r['name']!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: black,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Category: ${r['category']}",
                  style: const TextStyle(
                    color: dark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Points Requested: ${r['points']}",
                  style: const TextStyle(
                    color: dark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  height: 110,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: light),
                  ),
                  child: Center(
                    child: Text(
                      "Certificate Preview\n(${r['certificate']})",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: dark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  maxLines: 2,
                  decoration: remarkStyle(),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 14),
                        ),
                        onPressed: () =>
                            handleAction(index, true),
                        child: const Text(
                          "Approve",
                          style: TextStyle(
                              fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 14),
                        ),
                        onPressed: () =>
                            handleAction(index, false),
                        child: const Text(
                          "Reject",
                          style: TextStyle(
                              fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
