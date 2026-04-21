import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api.dart';

// ══════════════════════════════════════════════════════════
// MANAGE USERS PAGE
// ══════════════════════════════════════════════════════════
class ManageUsersPage extends StatefulWidget {
  const ManageUsersPage({super.key});

  @override
  State<ManageUsersPage> createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage>
    with SingleTickerProviderStateMixin {

  // ── Design tokens ────────────────────────────────────────
  static const _bg     = Color(0xFFF5F7FA);
  static const _navy   = Color(0xFF03305A);
  static const _white  = Colors.white;
  static const _border = Color(0xFFD8E3ED);
  static const _muted  = Color(0xFF6B7C93);
  static const _hint   = Color(0xFFAAB8C5);
  static const _green  = Color(0xFF1D9E75);
  static const _amber  = Color(0xFFF59E0B);
  static const _red    = Color(0xFFE24B4A);

  late TabController _tab;
  List<Map<String, dynamic>> faList   = [];
  List<Map<String, dynamic>> students = [];
  String _faSearch  = "";
  String _stuSearch = "";
  bool   _loading   = false;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    loadUsers();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  // ── Snackbar ──────────────────────────────────────────────
  void _toast(String t) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(t,
            style: const TextStyle(
                color: _white, fontWeight: FontWeight.w600)),
        backgroundColor: _navy,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ── Load users ───────────────────────────────────────────
  Future<void> loadUsers() async {
    setState(() => _loading = true);
    try {
      final res =
          await http.get(Uri.parse("$BASE_URL/admin/users"));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List;
        setState(() {
          faList = data
              .where((u) => u["role"] == "FA")
              .map<Map<String, dynamic>>((u) => {
                    "id":    u["id"].toString(),
                    "name":  u["name"],
                    "email": u["email"],
                  })
              .toList();
          students = data
              .where((u) => u["role"] == "STUDENT")
              .map<Map<String, dynamic>>((u) => {
                    "id":    u["id"].toString(),
                    "name":  u["name"],
                    "email": u["email"],
                    "faId":  u["faId"]?.toString() ?? "",
                  })
              .toList();
        });
      } else {
        _toast("Failed to load users (${res.statusCode})");
      }
    } catch (_) {
      _toast("Backend connection failed");
    } finally {
      setState(() => _loading = false);
    }
  }

  // ── Delete user ──────────────────────────────────────────
  Future<void> _deleteUser(String id) async {
    try {
      final res = await http
          .delete(Uri.parse("$BASE_URL/admin/delete/$id"));
      if (res.statusCode == 200) {
        _toast("User deleted");
        loadUsers();
      } else {
        _toast("Delete failed (${res.statusCode})");
      }
    } catch (_) {
      _toast("Backend connection failed");
    }
  }

  // ── Shared input decoration ───────────────────────────────
  InputDecoration _inputDec(String hint, {IconData? prefix}) =>
      InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: _hint, fontSize: 13),
        filled: true,
        fillColor: _bg,
        prefixIcon: prefix != null
            ? Icon(prefix, color: _hint, size: 18)
            : null,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _navy, width: 1.5),
        ),
      );

  // ── Add FA Dialog ─────────────────────────────────────────
  void _addFaDialog() {
    final nameCtrl  = TextEditingController();
    final empCtrl   = TextEditingController();
    final emailCtrl = TextEditingController();
    final deptCtrl  = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: _white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46, height: 46,
                decoration: BoxDecoration(
                    color: _navy,
                    borderRadius: BorderRadius.circular(14)),
                child: const Icon(Icons.person_add_rounded,
                    color: _white, size: 22),
              ),
              const SizedBox(height: 14),
              const Text("Add Faculty Advisor",
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: _navy)),
              const SizedBox(height: 4),
              const Text("Default password: 1234",
                  style: TextStyle(color: _muted, fontSize: 12)),
              const SizedBox(height: 18),
              _dialogField(nameCtrl,  "Full name",   Icons.person_outline_rounded),
              const SizedBox(height: 10),
              _dialogField(emailCtrl, "Email",        Icons.mail_outline_rounded),
              const SizedBox(height: 10),
              _dialogField(empCtrl,   "Employee ID",  Icons.badge_outlined),
              const SizedBox(height: 10),
              _dialogField(deptCtrl,  "Department",   Icons.business_outlined),
              const SizedBox(height: 22),
              _dialogActions(
                onCancel: () => Navigator.pop(context),
                onConfirm: () async {
                  await http.post(
                    Uri.parse("$BASE_URL/admin/add-fa"),
                    headers: {"Content-Type": "application/json"},
                    body: jsonEncode({
                      "name":     nameCtrl.text.trim(),
                      "email":    emailCtrl.text.trim(),
                      "empId":    empCtrl.text.trim(),
                      "password": "1234",
                      "dept":     deptCtrl.text.trim(),
                    }),
                  );
                  Navigator.pop(context);
                  loadUsers();
                },
                confirmLabel: "Add FA",
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Add Student Dialog ────────────────────────────────────
  void _addStudentDialog() {
    if (faList.isEmpty) {
      _toast("Create a Faculty Advisor first");
      return;
    }

    final nameCtrl  = TextEditingController();
    final emailCtrl = TextEditingController();
    final rollCtrl  = TextEditingController();
    final deptCtrl  = TextEditingController();
    String selectedFa = faList.first["id"];

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => Dialog(
          backgroundColor: _white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22)),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46, height: 46,
                  decoration: BoxDecoration(
                      color: _green.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14)),
                  child: const Icon(Icons.school_rounded,
                      color: _green, size: 22),
                ),
                const SizedBox(height: 14),
                const Text("Add Student",
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: _navy)),
                const SizedBox(height: 4),
                const Text("Default password: 1234",
                    style: TextStyle(color: _muted, fontSize: 12)),
                const SizedBox(height: 18),
                _dialogField(nameCtrl,  "Full name",     Icons.person_outline_rounded),
                const SizedBox(height: 10),
                _dialogField(rollCtrl,  "Roll number",   Icons.numbers_rounded),
                const SizedBox(height: 10),
                _dialogField(emailCtrl, "Email",          Icons.mail_outline_rounded),
                const SizedBox(height: 10),
                _dialogField(deptCtrl,  "Department",     Icons.business_outlined),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedFa,
                  dropdownColor: _white,
                  style: const TextStyle(color: _navy, fontSize: 14),
                  decoration: _inputDec("Faculty Advisor"),
                  items: faList
                      .map((fa) => DropdownMenuItem(
                            value: fa["id"] as String,
                            child: Text(fa["name"] as String),
                          ))
                      .toList(),
                  onChanged: (v) =>
                      setS(() => selectedFa = v ?? selectedFa),
                ),
                const SizedBox(height: 22),
                _dialogActions(
                  onCancel: () => Navigator.pop(ctx),
                  onConfirm: () async {
                    await http.post(
                      Uri.parse("$BASE_URL/admin/add-student"),
                      headers: {"Content-Type": "application/json"},
                      body: jsonEncode({
                        "name":     nameCtrl.text.trim(),
                        "email":    emailCtrl.text.trim(),
                        "password": "1234",
                        "dept":     deptCtrl.text.trim(),
                        "rollNo":   rollCtrl.text.trim(),
                        "faId":     int.parse(selectedFa),
                      }),
                    );
                    Navigator.pop(ctx);
                    loadUsers();
                  },
                  confirmLabel: "Add Student",
                  confirmColor: _green,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Delete Confirm Dialog ─────────────────────────────────
  void _deleteDialog(String id, String name) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: _white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46, height: 46,
                decoration: BoxDecoration(
                    color: _red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14)),
                child: const Icon(Icons.person_remove_rounded,
                    color: _red, size: 22),
              ),
              const SizedBox(height: 14),
              const Text("Delete User",
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: _navy)),
              const SizedBox(height: 6),
              Text('Remove "$name" permanently?',
                  style: const TextStyle(
                      color: _muted, fontSize: 13)),
              const SizedBox(height: 22),
              _dialogActions(
                onCancel: () => Navigator.pop(context),
                onConfirm: () {
                  Navigator.pop(context);
                  _deleteUser(id);
                },
                confirmLabel: "Delete",
                confirmColor: _red,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Dialog helpers ────────────────────────────────────────
  Widget _dialogField(
          TextEditingController ctrl, String hint, IconData icon) =>
      TextField(
        controller: ctrl,
        cursorColor: _navy,
        style: const TextStyle(color: _navy, fontSize: 14),
        decoration: _inputDec(hint, prefix: icon),
      );

  Widget _dialogActions({
    required VoidCallback onCancel,
    required VoidCallback onConfirm,
    required String confirmLabel,
    Color confirmColor = _navy,
  }) =>
      Row(children: [
        Expanded(
          child: TextButton(
            onPressed: onCancel,
            style: TextButton.styleFrom(
              foregroundColor: _muted,
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: _border),
              ),
            ),
            child: const Text("Cancel",
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: onConfirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor,
              foregroundColor: _white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(confirmLabel,
                style:
                    const TextStyle(fontWeight: FontWeight.w700)),
          ),
        ),
      ]);

  // ── App-bar icon button ───────────────────────────────────
  Widget _appBarBtn(IconData icon, VoidCallback onTap,
          {EdgeInsets margin =
              const EdgeInsets.only(right: 4)}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40, height: 40,
          margin: margin,
          decoration: BoxDecoration(
            color: _white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _border),
            boxShadow: [
              BoxShadow(
                color: _navy.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, color: _navy, size: 20),
        ),
      );

  // ── BUILD ────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final faFiltered = faList.where((fa) {
      final x = "${fa["name"]} ${fa["email"]}".toLowerCase();
      return x.contains(_faSearch.toLowerCase());
    }).toList();

    final stuFiltered = students.where((s) {
      final x = "${s["name"]} ${s["email"]}".toLowerCase();
      return x.contains(_stuSearch.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: _bg,

      // ── APP BAR ──────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: _navy),
        title: Row(
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                  color: _navy,
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.manage_accounts_rounded,
                  color: _white, size: 18),
            ),
            const SizedBox(width: 10),
            const Text(
              "Manage Users",
              style: TextStyle(
                color: _navy,
                fontWeight: FontWeight.w800,
                fontSize: 18,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        actions: [
          _appBarBtn(
            Icons.refresh_rounded,
            loadUsers,
            margin: const EdgeInsets.only(right: 12),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            height: 44,
            decoration: BoxDecoration(
              color: _white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _border),
            ),
            child: TabBar(
              controller: _tab,
              indicator: BoxDecoration(
                color: _navy,
                borderRadius: BorderRadius.circular(10),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: _white,
              unselectedLabelColor: _muted,
              labelStyle: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 13),
              dividerColor: Colors.transparent,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.people_alt_rounded, size: 15),
                      const SizedBox(width: 6),
                      Text("FA  (${faList.length})"),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.school_rounded, size: 15),
                      const SizedBox(width: 6),
                      Text("Students  (${students.length})"),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      // ── BODY ─────────────────────────────────────────────
      body: _loading
          ? _buildLoader()
          : TabBarView(
              controller: _tab,
              children: [

                // ── FA TAB ──────────────────────────────
                _UserTab(
                  searchHint:   "Search faculty advisors…",
                  onSearch:     (v) => setState(() => _faSearch = v),
                  addLabel:     "Add Faculty Advisor",
                  addIcon:      Icons.person_add_rounded,
                  addColor:     _navy,
                  onAdd:        _addFaDialog,
                  users:        faFiltered,
                  isFa:         true,
                  allStudents:  students,
                  onDelete:     _deleteDialog,
                ),

                // ── STUDENT TAB ─────────────────────────
                _UserTab(
                  searchHint:  "Search students…",
                  onSearch:    (v) => setState(() => _stuSearch = v),
                  addLabel:    "Add Student",
                  addIcon:     Icons.school_rounded,
                  addColor:    _green,
                  onAdd:       _addStudentDialog,
                  users:       stuFiltered,
                  isFa:        false,
                  allStudents: students,
                  onDelete:    _deleteDialog,
                ),
              ],
            ),
    );
  }

  Widget _buildLoader() => const Center(
        child: CircularProgressIndicator(
          strokeWidth: 3,
          valueColor: AlwaysStoppedAnimation<Color>(_navy),
          backgroundColor: _border,
        ),
      );
}

// ══════════════════════════════════════════════════════════
// USER TAB (reusable for FA + Students)
// ══════════════════════════════════════════════════════════
class _UserTab extends StatelessWidget {
  static const _bg    = Color(0xFFF5F7FA);
  static const _navy  = Color(0xFF03305A);
  static const _white = Colors.white;
  static const _border= Color(0xFFD8E3ED);
  static const _hint  = Color(0xFFAAB8C5);
  static const _muted = Color(0xFF6B7C93);

  final String   searchHint;
  final Function(String) onSearch;
  final String   addLabel;
  final IconData addIcon;
  final Color    addColor;
  final VoidCallback onAdd;
  final List<Map<String, dynamic>> users;
  final bool   isFa;
  final List   allStudents;
  final void Function(String id, String name) onDelete;

  const _UserTab({
    required this.searchHint,
    required this.onSearch,
    required this.addLabel,
    required this.addIcon,
    required this.addColor,
    required this.onAdd,
    required this.users,
    required this.isFa,
    required this.allStudents,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
          child: Column(
            children: [
              // Search
              TextField(
                onChanged: onSearch,
                cursorColor: _navy,
                style: const TextStyle(color: _navy, fontSize: 14),
                decoration: InputDecoration(
                  hintText: searchHint,
                  hintStyle:
                      const TextStyle(color: _hint, fontSize: 13),
                  filled: true,
                  fillColor: _white,
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: _hint, size: 18),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: _navy, width: 1.5),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Add button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: addColor,
                    foregroundColor: _white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13)),
                  ),
                  onPressed: onAdd,
                  icon: Icon(addIcon, size: 18),
                  label: Text(addLabel,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14)),
                ),
              ),

              const SizedBox(height: 10),

              // Count
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "${users.length} ${isFa ? 'advisor' : 'student'}${users.length == 1 ? '' : 's'}",
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        // List
        Expanded(
          child: users.isEmpty
              ? _buildEmpty()
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding:
                      const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  itemCount: users.length,
                  itemBuilder: (ctx, i) => _UserTile(
                    user:        users[i],
                    index:       i,
                    isFa:        isFa,
                    allStudents: allStudents,
                    onDelete:    onDelete,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildEmpty() => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68, height: 68,
              decoration: BoxDecoration(
                color: _white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _border),
              ),
              child: Icon(
                isFa
                    ? Icons.people_outline_rounded
                    : Icons.school_outlined,
                color: _hint,
                size: 32,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              isFa ? "No faculty advisors" : "No students",
              style: const TextStyle(
                color: _navy,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            const Text("Tap the button above to add one.",
                style: TextStyle(color: _muted, fontSize: 13)),
          ],
        ),
      );
}

// ══════════════════════════════════════════════════════════
// USER TILE  (staggered animation + press scale)
// ══════════════════════════════════════════════════════════
class _UserTile extends StatefulWidget {
  final Map<String, dynamic> user;
  final int   index;
  final bool  isFa;
  final List  allStudents;
  final void Function(String id, String name) onDelete;

  const _UserTile({
    required this.user,
    required this.index,
    required this.isFa,
    required this.allStudents,
    required this.onDelete,
  });

  @override
  State<_UserTile> createState() => _UserTileState();
}

class _UserTileState extends State<_UserTile>
    with SingleTickerProviderStateMixin {

  static const _navy   = Color(0xFF03305A);
  static const _white  = Colors.white;
  static const _border = Color(0xFFD8E3ED);
  static const _muted  = Color(0xFF6B7C93);
  static const _hint   = Color(0xFFAAB8C5);
  static const _green  = Color(0xFF1D9E75);
  static const _red    = Color(0xFFE24B4A);
  static const _bg     = Color(0xFFF5F7FA);

  late AnimationController _ctrl;
  late Animation<double>   _slide;
  late Animation<double>   _fade;
  bool _pressed = false;

  // Rotating avatar palette
  static const _avatarBgs = [
    Color(0xFFDCEAF8), Color(0xFFD1F0E5),
    Color(0xFFFDE8D0), Color(0xFFEDE1F8),
    Color(0xFFFFE0E0),
  ];
  static const _avatarFgs = [
    Color(0xFF03305A), Color(0xFF1D9E75),
    Color(0xFFF59E0B), Color(0xFF7C3AED),
    Color(0xFFE24B4A),
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300 + widget.index * 35),
    );
    _slide = Tween<double>(begin: 22, end: 0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _fade = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    Future.delayed(Duration(milliseconds: widget.index * 45), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String _initials(String name) {
    final parts = name.trim().split(" ");
    if (parts.length >= 2) return "${parts[0][0]}${parts[1][0]}".toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : "?";
  }

  @override
  Widget build(BuildContext context) {
    final u   = widget.user;
    final ci  = widget.index % _avatarBgs.length;
    final id  = u["id"] as String;
    final name  = u["name"] as String? ?? "—";
    final email = u["email"] as String? ?? "—";

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) => Opacity(
        opacity: _fade.value,
        child: Transform.translate(
            offset: Offset(0, _slide.value), child: child),
      ),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp:   (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.isFa
            ? () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FAStudentsPage(
                      faId:       id,
                      faName:     name,
                      allStudents: widget.allStudents,
                    ),
                  ),
                )
            : null,
        child: AnimatedScale(
          scale:    _pressed ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 110),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _border),
              boxShadow: [
                BoxShadow(
                  color: _navy.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 46, height: 46,
                  decoration: BoxDecoration(
                    color: _avatarBgs[ci],
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      _initials(name),
                      style: TextStyle(
                        color: _avatarFgs[ci],
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Name + email
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: const TextStyle(
                            color: _navy,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 3),
                      Text(email,
                          style: const TextStyle(
                              color: _muted, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      if (widget.isFa) ...[
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: _navy.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            "Faculty Advisor",
                            style: TextStyle(
                              color: _navy,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // FA: chevron, else delete
                if (widget.isFa)
                  Row(children: [
                    Container(
                      width: 28, height: 28,
                      decoration: BoxDecoration(
                        color: _bg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _border),
                      ),
                      child: const Icon(Icons.chevron_right_rounded,
                          size: 16, color: _hint),
                    ),
                    const SizedBox(width: 6),
                    _deleteBtn(id, name),
                  ])
                else
                  _deleteBtn(id, name),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _deleteBtn(String id, String name) => GestureDetector(
        onTap: () => widget.onDelete(id, name),
        child: Container(
          width: 34, height: 34,
          decoration: BoxDecoration(
            color: _red.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _red.withOpacity(0.2)),
          ),
          child: const Icon(Icons.delete_outline_rounded,
              size: 17, color: _red),
        ),
      );
}

// ══════════════════════════════════════════════════════════
// FA STUDENTS PAGE
// ══════════════════════════════════════════════════════════
class FAStudentsPage extends StatelessWidget {

  static const _bg     = Color(0xFFF5F7FA);
  static const _navy   = Color(0xFF03305A);
  static const _white  = Colors.white;
  static const _border = Color(0xFFD8E3ED);
  static const _muted  = Color(0xFF6B7C93);
  static const _hint   = Color(0xFFAAB8C5);

  final String faId;
  final String faName;
  final List   allStudents;

  const FAStudentsPage({
    super.key,
    required this.faId,
    required this.faName,
    required this.allStudents,
  });

  String _initials(String name) {
    final parts = name.trim().split(" ");
    if (parts.length >= 2) return "${parts[0][0]}${parts[1][0]}".toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : "?";
  }

  @override
  Widget build(BuildContext context) {
    final myStudents =
        allStudents.where((s) => s["faId"] == faId).toList();

    return Scaffold(
      backgroundColor: _bg,

      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: _navy),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              faName,
              style: const TextStyle(
                color: _navy,
                fontWeight: FontWeight.w800,
                fontSize: 16,
                letterSpacing: -0.2,
              ),
            ),
            Text(
              "${myStudents.length} student${myStudents.length == 1 ? '' : 's'} assigned",
              style: const TextStyle(
                color: _muted,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),

      body: myStudents.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 68, height: 68,
                    decoration: BoxDecoration(
                      color: _white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _border),
                    ),
                    child: const Icon(Icons.school_outlined,
                        color: _hint, size: 30),
                  ),
                  const SizedBox(height: 14),
                  const Text("No students assigned",
                      style: TextStyle(
                          color: _navy,
                          fontWeight: FontWeight.w700,
                          fontSize: 15)),
                  const SizedBox(height: 4),
                  const Text("Students will appear here once assigned.",
                      style: TextStyle(color: _muted, fontSize: 13)),
                ],
              ),
            )
          : ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: myStudents.length,
              itemBuilder: (ctx, i) {
                final s    = myStudents[i];
                final name = s["name"] as String? ?? "—";
                final avatarBgs = [
                  const Color(0xFFDCEAF8),
                  const Color(0xFFD1F0E5),
                  const Color(0xFFFDE8D0),
                  const Color(0xFFEDE1F8),
                  const Color(0xFFFFE0E0),
                ];
                final avatarFgs = [
                  _navy,
                  const Color(0xFF1D9E75),
                  const Color(0xFFF59E0B),
                  const Color(0xFF7C3AED),
                  const Color(0xFFE24B4A),
                ];
                final ci = i % avatarBgs.length;

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: _border),
                    boxShadow: [
                      BoxShadow(
                        color: _navy.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: avatarBgs[ci],
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Center(
                          child: Text(
                            _initials(name),
                            style: TextStyle(
                              color: avatarFgs[ci],
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name,
                                style: const TextStyle(
                                  color: _navy,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 3),
                            Text(s["email"] as String? ?? "—",
                                style: const TextStyle(
                                    color: _muted, fontSize: 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
