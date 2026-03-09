import 'package:flutter/material.dart';
import '../student/category_data.dart';

class ManageCategoriesPage extends StatefulWidget {
  const ManageCategoriesPage({super.key});

  @override
  State<ManageCategoriesPage> createState() => _ManageCategoriesPageState();
}

class _ManageCategoriesPageState extends State<ManageCategoriesPage> {
  static const bg = Color(0xFFE8E9EB);
  static const light = Color(0xFFCCCDC6);
  static const mid = Color(0xFFACADA8);
  //static const dark = Color(0xFF746D69);
  static const black = Color(0xFF262626);

  final search = TextEditingController();
  String filterType = "all";

  late List<Map<String, dynamic>> activities;

  // ================= BUILD FROM MASTER =================

  List<Map<String, dynamic>> buildActivities() {
    final List<Map<String, dynamic>> data = [];

    instituteData.forEach((main, sub) {
      sub.forEach((title, points) {
        data.add({
          "main": main,
          "title": title,
          "points": points,
          "type": "institute",
          "status": "active",
        });
      });
    });

    departmentData.forEach((main, sub) {
      sub.forEach((title, points) {
        data.add({
          "main": main,
          "title": title,
          "points": points,
          "type": "department",
          "status": "active",
        });
      });
    });

    return data;
  }

  @override
  void initState() {
    super.initState();
    activities = buildActivities(); // happens only once
  }

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  void msg(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  // ================= FILTER =================

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

  // ================= ADD =================

  void addDialog() {
    final titleController = TextEditingController();
    final pointsController = TextEditingController();

    String type = "institute";
    String? selectedMain;
    bool createNewMain = false;
    final newMainController = TextEditingController();

    List<String> getMains() {
      if (type == "institute") {
        return instituteData.keys.toList();
      } else {
        return departmentData.keys.toList();
      }
    }

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setLocalState) => AlertDialog(
          title: const Text("Add Activity"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(hintText: "Title"),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: pointsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: "Points"),
                ),
                const SizedBox(height: 10),

                // TYPE
                DropdownButtonFormField(
                  value: type,
                  items: const [
                    DropdownMenuItem(
                        value: "institute", child: Text("Institute")),
                    DropdownMenuItem(
                        value: "department", child: Text("Department")),
                  ],
                  onChanged: (v) {
                    setLocalState(() {
                      type = v.toString();
                      selectedMain = null;
                    });
                  },
                  decoration: const InputDecoration(labelText: "Type"),
                ),

                const SizedBox(height: 10),

                // EXISTING GROUP
                if (!createNewMain)
                  DropdownButtonFormField(
                    value: selectedMain,
                    items: getMains()
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) =>
                        setLocalState(() => selectedMain = v.toString()),
                    decoration:
                        const InputDecoration(labelText: "Select Group"),
                  ),

                const SizedBox(height: 10),

                // NEW GROUP SWITCH
                Row(
                  children: [
                    Checkbox(
                      value: createNewMain,
                      onChanged: (v) =>
                          setLocalState(() => createNewMain = v ?? false),
                    ),
                    const Text("Create new group"),
                  ],
                ),

                if (createNewMain)
                  TextField(
                    controller: newMainController,
                    decoration:
                        const InputDecoration(hintText: "New group name"),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () {
                final t = titleController.text.trim();
                final pts = int.tryParse(pointsController.text.trim());

                if (t.isEmpty || pts == null) {
                  msg("Invalid");
                  return;
                }

                final mainName = createNewMain
                    ? newMainController.text.trim()
                    : selectedMain;

                if (mainName == null || mainName.isEmpty) {
                  msg("Select group");
                  return;
                }

                setState(() {
                  activities.add({
                    "main": mainName,
                    "title": t,
                    "points": pts,
                    "type": type,
                    "status": "active",
                  });
                });

                Navigator.pop(context);
                msg("Added");
              },
              child: const Text("Add"),
            ),
          ],
        ),
      ),
    );
  }

  // ================= EDIT =================

  void editDialog(int index) {
    final titleController =
        TextEditingController(text: activities[index]["title"]);
    final pointsController =
        TextEditingController(text: activities[index]["points"].toString());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Activity"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController),
            const SizedBox(height: 10),
            TextField(
                controller: pointsController,
                keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              final t = titleController.text.trim();
              final pts = int.tryParse(pointsController.text.trim());

              if (t.isEmpty || pts == null) {
                msg("Invalid");
                return;
              }

              setState(() {
                activities[index]["title"] = t;
                activities[index]["points"] = pts;
              });

              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  // ================= DELETE =================

  void deleteDialog(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete"),
        content: Text(activities[index]["title"]),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() => activities.removeAt(index));
              Navigator.pop(context);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  // ================= UI =================

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
          IconButton(onPressed: addDialog, icon: const Icon(Icons.add)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: search,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: "Search activity",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text("Filter:",
                    style:
                        TextStyle(fontWeight: FontWeight.w800, color: black)),
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
            Expanded(
              child: ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, i) {
                  final a = list[i];
                  final realIndex = activities.indexOf(a);

                  final isInstitute = a["type"]?.toString() == "institute";

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
                        Icon(
                          isInstitute
                              ? Icons.apartment_rounded
                              : Icons.school_rounded,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(a["title"].toString(),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w900)),
                              Text("Points: ${a["points"]}"),
                              Text(a["main"].toString(),
                                  style: const TextStyle(
                                      fontSize: 12, color: mid)),
                            ],
                          ),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (val) {
                            if (val == "edit") {
                              editDialog(realIndex);
                            } else {
                              deleteDialog(realIndex);
                            }
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(value: "edit", child: Text("Edit")),
                            PopupMenuItem(
                                value: "delete", child: Text("Delete")),
                          ],
                        ),
                      ],
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
