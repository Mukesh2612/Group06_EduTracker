import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class ReviewApplicationPage extends StatefulWidget {
  const ReviewApplicationPage({super.key});

  @override
  State<ReviewApplicationPage> createState() => _ReviewApplicationPageState();
}

class _ReviewApplicationPageState extends State<ReviewApplicationPage> {
  static const bg = Color(0xFFE8E9EB);
  static const light = Color(0xFFCCCDC6);
  static const dark = Color(0xFF746D69);
  static const black = Color(0xFF262626);

  List requests = [];

  @override
  void initState() {
    super.initState();
    loadPending();
  }

  Future loadPending() async {
    final res = await http
        .get(Uri.parse("http://localhost:8080/api/submissions/pending"));

    if (res.statusCode == 200) {
      setState(() {
        requests = jsonDecode(res.body);
      });
    }
  }

  Future approve(int id) async {
    final res = await http
        .post(Uri.parse("http://localhost:8080/api/submissions/approve/$id"));

    if (res.statusCode == 200) {
      loadPending();
    }
  }

  Future reject(int id, String remark) async {
    final res = await http.put(
      Uri.parse(
          "http://localhost:8080/api/submissions/reject/$id?remarks=${Uri.encodeComponent(remark)}"),
    );
    if (res.statusCode == 200) {
      loadPending();
    }
  }

  void openFile(String filename) async {
    final encoded = Uri.encodeComponent(filename);

    final url = Uri.parse("http://localhost:8080/uploads/$encoded");

    if (await canLaunchUrl(url)) {
      launchUrl(url);
    }
  }

  void rejectDialog(int id) {
    TextEditingController remark = TextEditingController();

    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: const Text("Reject Application"),
            content: TextField(
              controller: remark,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: "Enter rejection remark",
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                onPressed: () {
                  if (remark.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Remark required")));
                    return;
                  }

                  reject(id, remark.text.trim());
                  Navigator.pop(context);
                },
                child: const Text("Reject"),
              )
            ],
          );
        });
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
          "Pending Applications",
          style: TextStyle(color: black, fontWeight: FontWeight.w900),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: requests.length,
        itemBuilder: (context, i) {
          final r = requests[i];

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
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
                  "${r["studentName"]} (${r["rollNo"]})",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  r["title"],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: black,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Category: ${r["category"]}",
                  style: const TextStyle(
                    color: dark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Points Requested: ${r["points"]}",
                  style: const TextStyle(
                    color: dark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () => openFile(r["proofFile"] ?? ""),
                  child: Row(
                    children: [
                      const Icon(Icons.attach_file, color: black),
                      const SizedBox(width: 6),
                      Text(
                        r["proofFile"] ?? "",
                        style: const TextStyle(
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        onPressed: () => approve(r["id"]),
                        child: const Text("Approve"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: () => rejectDialog(r["id"]),
                        child: const Text("Reject"),
                      ),
                    ),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
