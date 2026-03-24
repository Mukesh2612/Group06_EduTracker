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

  String faSearch = "";
  String stuSearch = "";

  @override
  void initState() {
    super.initState();
    tab = TabController(length: 2, vsync: this);
    loadUsers();
  }

  void toast(String t) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(t)));
  }

  // ================= LOAD USERS =================
  Future<void> loadUsers() async {

    try {

      final response =
      await http.get(Uri.parse("$BASE_URL/auth/users"));

      if (response.statusCode == 200) {

        final data = jsonDecode(response.body);

        setState(() {

          faList = data
              .where((u) => u["role"] == "FA")
              .map<Map<String, dynamic>>((u) => {
            "id": u["id"].toString(),
            "name": u["name"] ?? "",
            "email": u["email"] ?? ""
          })
              .toList();

          students = data
              .where((u) => u["role"] == "STUDENT")
              .map<Map<String, dynamic>>((u) => {
            "id": u["id"].toString(),
            "name": u["name"] ?? "",
            "email": u["email"] ?? "",
            "faId": u["faId"]?.toString() ?? ""
          })
              .toList();
        });
      }
    } catch (e) {
      toast("Backend connection failed");
    }
  }

  // ================= DELETE USER =================
  Future<void> deleteUser(String id) async {

    try {

      final response =
      await http.delete(Uri.parse("$BASE_URL/auth/delete/$id"));

      if (response.statusCode == 200) {

        toast("User deleted");
        loadUsers();

      } else {
        toast("Delete failed");
      }

    } catch (e) {
      toast("Backend connection failed");
    }
  }

  // ================= ADD FA =================
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

            TextField(key: const Key("faNameField"),controller: name, decoration: const InputDecoration(hintText: "Name")),
            const SizedBox(height: 10),

            TextField(key: const Key("faEmailField"), controller: email, decoration: const InputDecoration(hintText: "Email")),
            const SizedBox(height: 10),

            TextField(controller: empId, decoration: const InputDecoration(hintText: "Emp ID")),
            const SizedBox(height: 10),

            TextField(controller: dept, decoration: const InputDecoration(hintText: "Department")),
          ],
        ),
        actions: [

          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),

          ElevatedButton(
            key: const Key("submitFaButton"),
            onPressed: () async {

              await http.post(
                Uri.parse("$BASE_URL/auth/add-fa"),
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

  // ================= ADD STUDENT =================
  void addStudent() {

    if (faList.isEmpty) {
      toast("Create Faculty Advisor first");
      return;
    }

    final name = TextEditingController();
    final email = TextEditingController();
    final roll = TextEditingController();
    final dept = TextEditingController();

    String selectedFa = faList.first["id"];

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Student"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            TextField(controller: name, decoration: const InputDecoration(hintText: "Name")),
            const SizedBox(height: 10),

            TextField(controller: roll, decoration: const InputDecoration(hintText: "Roll Number")),
            const SizedBox(height: 10),

            TextField(controller: email, decoration: const InputDecoration(hintText: "Email")),
            const SizedBox(height: 10),

            TextField(controller: dept, decoration: const InputDecoration(hintText: "Department")),
            const SizedBox(height: 10),

            DropdownButtonFormField(
              value: selectedFa,
              items: faList.map((fa) {
                return DropdownMenuItem(
                  value: fa["id"],
                  child: Text(fa["name"] ?? ""),
                );
              }).toList(),
              onChanged: (v) => selectedFa = v.toString(),
              decoration: const InputDecoration(labelText: "Faculty Advisor"),
            )
          ],
        ),
        actions: [

          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),

          ElevatedButton(
            onPressed: () async {

              await http.post(
                Uri.parse("$BASE_URL/auth/add-student"),
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

  // ================= USER CARD =================
  Widget userCard(String id, String name, String email, {bool isFa = false}) {

    return InkWell(

      onTap: isFa
          ? () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FAStudentsPage(
              faId: id,
              faName: name,
              students: students,
            ),
          ),
        );
      }
          : null,

      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: light),
        ),
        child: Row(
          children: [

            CircleAvatar(
              backgroundColor: black,
              child: Text(
                  (name.isNotEmpty ? name[0] : "?").toUpperCase(),
                style: const TextStyle(color: bg, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 16)),
                  const SizedBox(height: 3),
                  Text(email, style: const TextStyle(color: dark)),
                ],
              ),
            ),

            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {

                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Delete User"),
                    content: const Text("Are you sure you want to delete this user?"),
                    actions: [

                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        onPressed: () {
                          Navigator.pop(context);
                          deleteUser(id);
                        },
                        child: const Text("Delete"),
                      )
                    ],
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {

    final faFiltered = faList.where((fa) {
      final x = "${fa["name"]} ${fa["email"]}".toLowerCase();
      return x.contains(faSearch.toLowerCase());
    }).toList();

    final stuFiltered = students.where((s) {
      final x = "${s["name"]} ${s["email"]}".toLowerCase();
      return x.contains(stuSearch.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: bg,
      key: const Key("manageUsersPage"),
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        iconTheme: const IconThemeData(color: black),
        title: const Text(
          "Manage Users",
          style: TextStyle(color: black, fontWeight: FontWeight.w800),
        ),
        bottom: TabBar(
          controller: tab,
          labelColor: black,
          unselectedLabelColor: dark,
          indicatorColor: black,
          tabs: const [
            Tab(text: "Faculty Advisors"),
            Tab(text: "Students"),
          ],
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(18),
        child: TabBarView(
          controller: tab,
          children: [

            // ---------- FA TAB ----------
            Column(
              children: [

                TextField(
                  decoration: const InputDecoration(
                    hintText: "Search Faculty Advisor",
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (v) => setState(() => faSearch = v),
                ),

                const SizedBox(height: 14),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    key: const Key("addFaButton"),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: black,
                        foregroundColor: bg),
                    onPressed: addFa,
                    icon: const Icon(Icons.person_add),
                    label: const Text("Add Faculty Advisor"),
                  ),
                ),

                const SizedBox(height: 18),

                Expanded(
                  child: ListView.builder(
                    itemCount: faFiltered.length,
                    itemBuilder: (_, i) {
                      final fa = faFiltered[i];
                      return userCard(
                          fa["id"], fa["name"], fa["email"],
                          isFa: true);
                    },
                  ),
                ),
              ],
            ),

            // ---------- STUDENT TAB ----------
            Column(
              children: [

                TextField(
                  decoration: const InputDecoration(
                    hintText: "Search Student",
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (v) => setState(() => stuSearch = v),
                ),

                const SizedBox(height: 14),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    key: const Key("addStudentButton"),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: black,
                        foregroundColor: bg),
                    onPressed: addStudent,
                    icon: const Icon(Icons.person_add),
                    label: const Text("Add Student"),
                  ),
                ),

                const SizedBox(height: 18),

                Expanded(
                  child: ListView.builder(
                    itemCount: stuFiltered.length,
                    itemBuilder: (_, i) {
                      final s = stuFiltered[i];
                      return userCard(s["id"], s["name"], s["email"]);
                    },
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

class FAStudentsPage extends StatelessWidget {

  final String faId;
  final String faName;
  final List students;

  const FAStudentsPage({
    super.key,
    required this.faId,
    required this.faName,
    required this.students,
  });

  @override
  Widget build(BuildContext context) {

    final faStudents =
    students.where((s) => s["faId"] == faId).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text("$faName's Students"),
      ),

      body: faStudents.isEmpty
          ? const Center(child: Text("No students assigned"))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: faStudents.length,
        itemBuilder: (_, i) {

          final s = faStudents[i];

          return Card(
            child: ListTile(
              leading: CircleAvatar(
                child: Text(
                  s["name"][0].toUpperCase(),
                ),
              ),
              title: Text(s["name"]),
              subtitle: Text(s["email"]),
            ),
          );
        },
      ),
    );
  }
}