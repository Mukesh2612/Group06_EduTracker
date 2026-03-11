import 'package:flutter/material.dart';

class ManageCategoriesPage extends StatefulWidget {
  const ManageCategoriesPage({super.key});

  @override
  State<ManageCategoriesPage> createState() => _ManageCategoriesPageState();
}

class _ManageCategoriesPageState extends State<ManageCategoriesPage> {
  // Theme colors
  static const bg = Color(0xFFE8E9EB);
  static const light = Color(0xFFCCCDC6);
  static const mid = Color(0xFFACADA8);
  static const dark = Color(0xFF746D69);
  static const black = Color(0xFF262626);

  final search = TextEditingController();
  String filterType = "all"; // all, institute, department

  final List<Map<String, dynamic>> activities = [
    // Institute Level
    {
      "title": "Presenting paper outside Institute",
      "points": 10,
      "type": "institute",
      "status": "active",
    },
    {
      "title": "Presenting paper inside Institute",
      "points": 5,
      "type": "institute",
      "status": "active",
    },
    {
      "title": "Participating in conferences/workshops",
      "points": 3,
      "type": "institute",
      "status": "active",
    },
    {
      "title": "Prize winners (club events)",
      "points": 5,
      "type": "institute",
      "status": "active",
    },
    {
      "title": "Coordinator (event)",
      "points": 5,
      "type": "institute",
      "status": "active",
    },
    {
      "title": "Team lead (event)",
      "points": 3,
      "type": "institute",
      "status": "active",
    },
    {
      "title": "Student volunteer (event)",
      "points": 2,
      "type": "institute",
      "status": "active",
    },
    {
      "title": "Club office bearer (per semester)",
      "points": 3,
      "type": "institute",
      "status": "active",
    },
    {
      "title": "Club member (per semester)",
      "points": 2,
      "type": "institute",
      "status": "active",
    },
    {
      "title": "SAC Executive Member (per semester)",
      "points": 10,
      "type": "institute",
      "status": "active",
    },
    {
      "title": "Institute level competition participation",
      "points": 5,
      "type": "institute",
      "status": "active",
    },
    {
      "title": "Institute level competition prize winner",
      "points": 10,
      "type": "institute",
      "status": "active",
    },
    {
      "title": "District level participation",
      "points": 10,
      "type": "institute",
      "status": "active",
    },
    {
      "title": "District level prize winner",
      "points": 15,
      "type": "institute",
      "status": "active",
    },
    {
      "title": "State level participation",
      "points": 15,
      "type": "institute",
      "status": "active",
    },
    {
      "title": "State level prize winner",
      "points": 20,
      "type": "institute",
      "status": "active",
    },
    {
      "title": "National level participation",
      "points": 20,
      "type": "institute",
      "status": "active",
    },
    {
      "title": "National level prize winner",
      "points": 25,
      "type": "institute",
      "status": "active",
    },

    // NSS / NCC
    {
      "title": "NSS Participation (basic events)",
      "points": 5,
      "type": "institute",
      "status": "active",
    },
    {
      "title": "NSS Annual Camp",
      "points": 20,
      "type": "institute",
      "status": "active",
    },
    {
      "title": "NCC Institutional training (per semester)",
      "points": 5,
      "type": "institute",
      "status": "active",
    },
    {
      "title": "NCC C Certificate Exam (directorate level)",
      "points": 30,
      "type": "institute",
      "status": "active",
    },

    // Department Level
    {
      "title": "Environmental Studies (mandatory)",
      "points": 5,
      "type": "department",
      "status": "active",
    },
    {
      "title": "Value Education (mandatory)",
      "points": 5,
      "type": "department",
      "status": "active",
    },
    {
      "title": "Indian Constitution (mandatory)",
      "points": 5,
      "type": "department",
      "status": "active",
    },
    {
      "title": "Department Association - Participation (per activity)",
      "points": 2,
      "type": "department",
      "status": "active",
    },
    {
      "title": "Class Representative (per semester per rep)",
      "points": 5,
      "type": "department",
      "status": "active",
    },
    {
      "title": "Any other activity assigned by FA",
      "points": 2,
      "type": "department",
      "status": "active",
    },
  ];

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  void msg(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  List<Map<String, dynamic>> get filteredList {
    final q = search.text.trim().toLowerCase();

    return activities.where((a) {
      final title = a["title"].toString().toLowerCase();
      final type = a["type"].toString().toLowerCase();

      final matchSearch = q.isEmpty || title.contains(q);
      final matchType = filterType == "all" ? true : type == filterType;

      return matchSearch && matchType;
    }).toList();
  }

  Color typeColor(String type) {
    return type == "institute" ? Colors.blueGrey : Colors.deepPurple;
  }

  void addDialog() {
    final titleController = TextEditingController();
    final pointsController = TextEditingController();
    String type = "institute";
    String status = "active";

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Activity Category"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(hintText: "Activity title"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: pointsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: "Points"),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField(
              value: type,
              items: const [
                DropdownMenuItem(
                  value: "institute",
                  child: Text("Institute Level"),
                ),
                DropdownMenuItem(
                  value: "department",
                  child: Text("Department Level"),
                ),
              ],
              onChanged: (v) => type = v.toString(),
              decoration: const InputDecoration(labelText: "Type"),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField(
              value: status,
              items: const [
                DropdownMenuItem(value: "active", child: Text("Active")),
                DropdownMenuItem(value: "inactive", child: Text("Inactive")),
              ],
              onChanged: (v) => status = v.toString(),
              decoration: const InputDecoration(labelText: "Status"),
            ),
          ],
        ),
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
              final t = titleController.text.trim();
              final pts = int.tryParse(pointsController.text.trim());

              if (t.isEmpty || pts == null) {
                msg("Enter valid title and points");
                return;
              }

              setState(() {
                activities.add({
                  "title": t,
                  "points": pts,
                  "type": type,
                  "status": status,
                });
              });

              Navigator.pop(context);
              msg("Added (UI only)");
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  void editDialog(int index) {
    final titleController =
    TextEditingController(text: activities[index]["title"]);
    final pointsController =
    TextEditingController(text: activities[index]["points"].toString());

    String type = activities[index]["type"];
    String status = activities[index]["status"];

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Activity Category"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(hintText: "Activity title"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: pointsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: "Points"),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField(
              value: type,
              items: const [
                DropdownMenuItem(
                  value: "institute",
                  child: Text("Institute Level"),
                ),
                DropdownMenuItem(
                  value: "department",
                  child: Text("Department Level"),
                ),
              ],
              onChanged: (v) => type = v.toString(),
              decoration: const InputDecoration(labelText: "Type"),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField(
              value: status,
              items: const [
                DropdownMenuItem(value: "active", child: Text("Active")),
                DropdownMenuItem(value: "inactive", child: Text("Inactive")),
              ],
              onChanged: (v) => status = v.toString(),
              decoration: const InputDecoration(labelText: "Status"),
            ),
          ],
        ),
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
              final t = titleController.text.trim();
              final pts = int.tryParse(pointsController.text.trim());

              if (t.isEmpty || pts == null) {
                msg("Enter valid title and points");
                return;
              }

              setState(() {
                activities[index]["title"] = t;
                activities[index]["points"] = pts;
                activities[index]["type"] = type;
                activities[index]["status"] = status;
              });

              Navigator.pop(context);
              msg("Updated (UI only)");
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void deleteDialog(int index) {
    final name = activities[index]["title"];

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete"),
        content: Text("Delete this activity?\n\n$name"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              setState(() => activities.removeAt(index));
              Navigator.pop(context);
              msg("Deleted (UI only)");
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = filteredList;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        iconTheme: const IconThemeData(color: black),
        title: const Text(
          "Manage Activity Categories",
          style: TextStyle(color: black, fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            onPressed: addDialog,
            icon: const Icon(Icons.add_circle_outline),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search
            TextField(
              controller: search,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: "Search activity",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: light),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: black, width: 1.5),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Filter
            Row(
              children: [
                const Text(
                  "Filter:",
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: black,
                  ),
                ),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: filterType,
                  items: const [
                    DropdownMenuItem(value: "all", child: Text("All")),
                    DropdownMenuItem(
                        value: "institute", child: Text("Institute")),
                    DropdownMenuItem(
                        value: "department", child: Text("Department")),
                  ],
                  onChanged: (v) => setState(() => filterType = v ?? "all"),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // List
            Expanded(
              child: list.isEmpty
                  ? const Center(
                child: Text(
                  "No activities found",
                  style: TextStyle(color: dark),
                ),
              )
                  : ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, i) {
                  final a = list[i];
                  final realIndex = activities.indexOf(a);

                  final isActive = a["status"] == "active";
                  final isInstitute = a["type"] == "institute";

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: light),
                    ),
                    child: Row(
                      children: [
                        // icon box
                        Container(
                          height: 48,
                          width: 48,
                          decoration: BoxDecoration(
                            color: bg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: light),
                          ),
                          child: Icon(
                            isInstitute
                                ? Icons.apartment_rounded
                                : Icons.school_rounded,
                            color: black,
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Title + Points
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                a["title"],
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  color: black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Points: ${a["points"]}",
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: dark,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  // Type chip
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: typeColor(a["type"])
                                          .withOpacity(0.12),
                                      borderRadius:
                                      BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      a["type"]
                                          .toString()
                                          .toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w900,
                                        color: typeColor(a["type"]),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),

                                  // Status chip
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isActive
                                          ? const Color(0xFFEAF7EA)
                                          : const Color(0xFFFFEAEA),
                                      borderRadius:
                                      BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      isActive ? "ACTIVE" : "INACTIVE",
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w900,
                                        color: isActive
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // menu
                        PopupMenuButton<String>(
                          onSelected: (val) {
                            if (val == "edit") {
                              editDialog(realIndex);
                            } else if (val == "delete") {
                              deleteDialog(realIndex);
                            }
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(
                              value: "edit",
                              child: Text("Edit"),
                            ),
                            PopupMenuItem(
                              value: "delete",
                              child: Text("Delete"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // footer
            Padding(
              padding: const EdgeInsets.only(top: 6, bottom: 6),
              child: Text(
                "UI only • Based on NITC activity points list",
                style: TextStyle(color: mid, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
