import 'package:flutter/material.dart';
import 'management.dart';

class FADashboard extends StatelessWidget {
  const FADashboard({super.key});

  @override
  Widget build(BuildContext context) {

    final List<Map<String, String>> students = [
      {'name': 'Rahul Patel', 'roll': 'NIT2021', 'points': '20'},
      {'name': 'Mukesh', 'roll': 'NIT2022', 'points': '18'},
      {'name': 'Varshith', 'roll': 'NIT2023', 'points': '15'},
      {'name': 'Thanooj', 'roll': 'NIT2024', 'points': '22'},
      {'name': 'Pranathi', 'roll': 'NIT2024', 'points': '22'},
      {'name': 'Sneha Gupta', 'roll': 'NIT2024', 'points': '22'},
      {'name': 'Sneha Gupta', 'roll': 'NIT2024', 'points': '22'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Faculty Advisor Dashboard"),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // FA DETAILS
            Card(
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.person),
                ),
                title: const Text("Dr. A. Dhiraj"),
                subtitle: const Text("Faculty Advisor • CSE"),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Assigned Students",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            // STUDENT LIST
            Expanded(
              child: ListView.builder(
                itemCount: students.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.school),
                      title: Text(students[index]['name']!),
                      subtitle: Text(
                        "Roll: ${students[index]['roll']} | Points: ${students[index]['points']}",
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            // VIEW PENDING REQUESTS BUTTON (AFTER LIST)
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.pending_actions),
                label: const Text("View Pending Requests"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PendingRequestsPage(),
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
