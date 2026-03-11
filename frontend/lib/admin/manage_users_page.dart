import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api.dart';

class ManageUsersPage extends StatefulWidget {
  const ManageUsersPage({super.key});

  @override
  State<ManageUsersPage> createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage>
    with SingleTickerProviderStateMixin {
  static const bg = Color(0xFFE8E9EB);
  static const light = Color(0xFFCCCDC6);
  static const dark = Color(0xFF746D69);
  static const black = Color(0xFF262626);

  late TabController tab;

  List<Map<String, dynamic>> faList = [];
  List<Map<String, dynamic>> students = [];

  Future<void> loadUsers() async {
    try {

      final url = Uri.parse("$BASE_URL/admin/users");
      final response = await http.get(url);

      if (response.statusCode == 200) {

        final data = jsonDecode(response.body);

        setState(() {

          faList = data
              .where((u) => u["role"] == "FA")
              .map<Map<String, dynamic>>((u) => {
            "id": u["id"].toString(),
            "name": u["name"],
            "email": u["email"]
          }).toList();

          students = data
              .where((u) => u["role"] == "STUDENT")
              .map<Map<String, dynamic>>((u) => {
            "name": u["name"],
            "email": u["email"],
            "faId": u["faId"]?.toString() ?? ""
          }).toList();
        });

      }

    } catch (e) {
      toast("Backend connection failed");
    }
  }

  String faSearch = "", stuSearch = "";

  @override
  void initState() {
    super.initState();
    tab = TabController(length: 2, vsync: this);
    loadUsers();
  }

  @override
  void dispose() {
    tab.dispose();
    super.dispose();
  }

  void toast(String t) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));

  int countStudents(String faId) =>
      students.where((s) => s["faId"] == faId).length;

  String faName(String faId) {
    final fa = faList.firstWhere(
          (x) => x["id"] == faId,
      orElse: () => {"name": "NA"},
    );

    return fa["name"] ?? "NA";
  }

  InputDecoration searchDec(String hint) => InputDecoration(
    hintText: hint,
    prefixIcon: const Icon(Icons.search),
    filled: true,
    fillColor: Colors.white,
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: light),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: black, width: 1.4),
    ),
  );

  ButtonStyle btn() => ElevatedButton.styleFrom(
    backgroundColor: black,
    foregroundColor: bg,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );

  // ---------------- ADD FA ----------------
  void addFa() {

    final name = TextEditingController();
    final empId = TextEditingController();
    final email = TextEditingController();
    final dept = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Faculty Advisor"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            TextField(
              controller: name,
              decoration: const InputDecoration(hintText: "Name"),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: email,
              decoration: const InputDecoration(hintText: "Email"),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: empId,
              decoration: const InputDecoration(hintText: "EmpID"),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: dept,
              decoration: const InputDecoration(hintText: "Department"),
            ),

          ],
        ),
        actions: [

          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),

          ElevatedButton(
            onPressed: () async {

              if (name.text.isEmpty || email.text.isEmpty || dept.text.isEmpty) {
                toast("Fill all fields");
                return;
              }

              await http.post(
                Uri.parse("$BASE_URL/admin/add-fa"),
                headers: {"Content-Type": "application/json"},
                body: jsonEncode({
                  "name": name.text.trim(),
                  "email": email.text.trim(),
                  "empId": empId.text.trim(),
                  "password": "1234",
                  "dept": dept.text.trim()
                }),
              );

              Navigator.pop(context);
              loadUsers();
            },
            child: const Text("Add"),
          )

        ],
      ),
    );
  }

  Future<void> loadFAByDept(String dept) async {

    final response = await http.get(
      Uri.parse("$BASE_URL/admin/fa?dept=$dept"),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      setState(() {
        faList = data.map((fa) => {
          "id": fa["id"].toString(),
          "name": fa["name"]
        }).toList();
      });
    }
  }

  // ---------------- ADD STUDENT ----------------

  void addStudent({String? preSelectedFa}) {

    if (faList.isEmpty) {
      toast("Create a Faculty Advisor first");
      return;
    }

    final name = TextEditingController();
    final email = TextEditingController();
    final roll = TextEditingController();
    final dept = TextEditingController();

    String selectedFa = preSelectedFa ?? (faList.isNotEmpty ? faList.first["id"] : "");

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Student"),
        content: StatefulBuilder(
          builder: (context, setLocalState) {

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                TextField(
                  controller: name,
                  decoration: const InputDecoration(hintText: "Name"),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: roll,
                  decoration: const InputDecoration(hintText: "Roll Number"),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: email,
                  decoration: const InputDecoration(hintText: "Email"),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: dept,
                  decoration: const InputDecoration(hintText: "Department"),
                  onChanged: (value) async {

                    if (value.isNotEmpty) {

                      final response = await http.get(
                        Uri.parse("$BASE_URL/admin/fa?dept=${value.trim()}"),
                      );

                      if (response.statusCode == 200) {

                        final List data = jsonDecode(response.body);

                        setLocalState(() {
                          faList = data.map((fa) => {
                            "id": fa["id"].toString(),
                            "name": fa["name"]
                          }).toList();

                          if (faList.isNotEmpty) {
                            selectedFa = faList.first["id"];
                          }
                        });

                      }
                    }
                  },
                ),

                const SizedBox(height: 10),

                DropdownButtonFormField(
                  value: selectedFa,
                  items: faList.map((fa) {
                    return DropdownMenuItem(
                      value: fa["id"],
                      child: Text(fa["name"] ?? "Unknown"),
                    );
                  }).toList(),
                  onChanged: preSelectedFa != null
                      ? null
                      : (v) {
                    setLocalState(() {
                      selectedFa = v.toString();
                    });
                  },
                  decoration: const InputDecoration(labelText: "Faculty Advisor"),
                )

              ],
            );
          },
        ),

        actions: [

          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),

          ElevatedButton(
            onPressed: () async {

              await http.post(

                Uri.parse("$BASE_URL/admin/add-student"),
                headers: {"Content-Type": "application/json"},
                body: jsonEncode({
                  "name": name.text.trim(),
                  "email": email.text.trim(),
                  "password": "1234",
                  "dept": dept.text.trim(),
                  "rollNo": roll.text.trim(),
                  "faId": selectedFa
                }),
              );

              Navigator.pop(context);
              loadUsers();
            },
            child: const Text("Add"),
          )

        ],
      ),
    );
  }
  // ---------------- UI TILES ----------------
  Widget faTile(Map<String, dynamic> fa) {
    final c = countStudents(fa["id"] ?? "");

    return InkWell(
      onTap: () async {
        final updated = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FaStudentsPage(
              faId: fa["id"]!,
              faName: fa["name"] ?? "Unknown",
              students: students.map((e) => {
                "name": e["name"]?.toString() ?? "",
                "email": e["email"]?.toString() ?? "",
                "roll": e["roll"]?.toString() ?? "",
                "faId": e["faId"]?.toString() ?? ""
              }).toList(),
            ),
          ),
        );


        if (updated != null && updated is List<Map<String, String>>) {
          setState(() {
            students = updated.map((e) => {
              "name": e["name"],
              "email": e["email"],
              "roll": e["roll"],
              "faId": e["faId"]
            }).toList();
          });
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: light),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: black,
              child: Text(
                  ((fa["name"] ?? "U").toString().isNotEmpty
                      ? (fa["name"] ?? "U")[0]
                      : "U")
                      .toUpperCase(),
                  style: const TextStyle(color: bg, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(fa["name"] ?? "Unknown",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Text(fa["email"] ?? "", style: const TextStyle(color: dark)),
                  const SizedBox(height: 6),
                  Text("Students: $c",
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: dark),
          ],
        ),
      ),
    );
  }

  Widget studentTile(Map<String, dynamic> s, int i) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: light),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: black,
            child: Text(
              ((s["name"] ?? "U").toString().isNotEmpty
                  ? (s["name"] ?? "U")[0]
                  : "U")
                  .toUpperCase(),
              style: const TextStyle(color: bg, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s["name"] ?? "Unknown",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(s["email"] ?? "", style: const TextStyle(color: dark)),
                const SizedBox(height: 6),
                Text("FA: ${faName(s["faId"] ?? "")}",
                    style: const TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          IconButton(
            onPressed: () => setState(() => students.removeAt(i)),
            icon: const Icon(Icons.delete_outline, color: Colors.red),
          ),
        ],
      ),
    );
  }

  // ---------------- MAIN ----------------
  @override
  Widget build(BuildContext context) {
    final faFiltered = faList.where((fa) {
      final x = "${fa["name"]} ${fa["email"]}".toLowerCase();
      return x.contains(faSearch.toLowerCase());
    }).toList();

    final stuFiltered = students.where((s) {
      final x = "${s["name"]} ${s["email"]} ${faName(s["faId"] ?? "")}".toLowerCase();
      return x.contains(stuSearch.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        iconTheme: const IconThemeData(color: black),
        title: const Text("Manage Users",
            style: TextStyle(color: black, fontWeight: FontWeight.w800)),
        bottom: TabBar(
          controller: tab,
          labelColor: black,
          unselectedLabelColor: dark,
          indicatorColor: black,
          tabs: const [Tab(text: "Faculty Advisors"), Tab(text: "Students")],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: TabBarView(
          controller: tab,
          children: [
            // FA TAB
            Column(
              children: [
                TextField(
                  decoration: searchDec("Search Faculty Advisor..."),
                  onChanged: (v) => setState(() => faSearch = v),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    style: btn(),
                    onPressed: addFa,
                    icon: const Icon(Icons.person_add_alt_1),
                    label: const Text("Add Faculty Advisor",
                        style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: ListView.builder(
                    itemCount: faFiltered.length,
                    itemBuilder: (_, i) => faTile(faFiltered[i]),
                  ),
                ),
              ],
            ),

            // STUDENT TAB
            Column(
              children: [
                TextField(
                  decoration: searchDec("Search Student / FA..."),
                  onChanged: (v) => setState(() => stuSearch = v),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    style: btn(),
                    onPressed: addStudent,
                    icon: const Icon(Icons.person_add),
                    label: const Text("Add Student",
                        style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: ListView.builder(
                    itemCount: stuFiltered.length,
                    itemBuilder: (_, i) => studentTile(stuFiltered[i], i),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ======================================================
// FA STUDENTS PAGE (MINIMAL)
// ======================================================
class FaStudentsPage extends StatefulWidget {
  final String faId;
  final String faName;
  final List<Map<String, String>> students;

  const FaStudentsPage({
    super.key,
    required this.faId,
    required this.faName,
    required this.students,
  });

  @override
  State<FaStudentsPage> createState() => _FaStudentsPageState();
}

class _FaStudentsPageState extends State<FaStudentsPage>
    with SingleTickerProviderStateMixin {
  static const bg = Color(0xFFE8E9EB);
  static const light = Color(0xFFCCCDC6);
  static const dark = Color(0xFF746D69);
  static const black = Color(0xFF262626);

  late List<Map<String, String>> students;
  String search = "";

  @override
  void initState() {
    super.initState();
    students = widget.students;
  }

  void addStudentHere() {
    final n = TextEditingController();
    final e = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Add Student to ${widget.faName}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: n, decoration: const InputDecoration(hintText: "Student Name")),
            const SizedBox(height: 10),
            TextField(controller: e, decoration: const InputDecoration(hintText: "Student Email")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: black),
            onPressed: () {
              if (n.text.trim().isEmpty || e.text.trim().isEmpty) return;
              setState(() {
                students.add({"name": n.text.trim(), "email": e.text.trim(), "faId": widget.faId});
              });
              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final faStudents = students.where((s) => s["faId"] == widget.faId).toList();

    final filtered = faStudents.where((s) {
      final x = "${s["name"]} ${s["email"]}".toLowerCase();
      return x.contains(search.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        iconTheme: const IconThemeData(color: black),
        title: Text("${widget.faName} Students",
            style: const TextStyle(color: black, fontWeight: FontWeight.w800)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: "Search student...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: light),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: black, width: 1.4),
                ),
              ),
              onChanged: (v) => setState(() => search = v),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: black,
                  foregroundColor: bg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.person_add),
                label: const Text("Add Student",
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (_, i) {
                  final s = filtered[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: light),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: black,
                          child: Text(
                              ((s["name"] ?? "U").toString().isNotEmpty
                                  ? (s["name"] ?? "U")[0]
                                  : "U")
                                  .toUpperCase(),
                              style: const TextStyle(
                                  color: bg, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(s["name"] ?? "Unknown",
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800)),
                              const SizedBox(height: 2),
                              Text(s["email"] ?? "",
                                  style: const TextStyle(color: dark)),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => setState(() => students.remove(s)),
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.red),
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: black,
        onPressed: () {
          Navigator.pop(context, students);
        },
        child: const Icon(Icons.check, color: bg),
      ),
    );
  }
}
