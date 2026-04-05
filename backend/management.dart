import 'package:flutter/material.dart';

class PendingRequestsPage extends StatelessWidget {
  const PendingRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {

    // Dummy requests data
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
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Pending Requests"),
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: requests.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // STUDENT NAME
                  Text(
                    requests[index]['name']!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text("Category: ${requests[index]['category']}"),
                  Text("Points: ${requests[index]['points']}"),

                  const SizedBox(height: 10),

                  // CERTIFICATE PREVIEW
                  Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text("Certificate Preview"),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // REMARKS FIELD
                  const TextField(
                    decoration: InputDecoration(
                      labelText: "Remarks",
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),

                  const SizedBox(height: 12),

                  // APPROVE / REJECT BUTTONS
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          onPressed: () {
                            // Approve logic later
                          },
                          child: const Text("Approve"),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          onPressed: () {
                            // Reject logic later
                          },
                          child: const Text("Reject"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
