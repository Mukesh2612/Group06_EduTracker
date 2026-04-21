import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/api.dart';

// ══════════════════════════════════════════════════════════
// MANAGE CATEGORIES PAGE
// ══════════════════════════════════════════════════════════
class ManageCategoriesPage extends StatefulWidget {
  const ManageCategoriesPage({super.key});

  @override
  State<ManageCategoriesPage> createState() => _ManageCategoriesPageState();
}

class _ManageCategoriesPageState extends State<ManageCategoriesPage>
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

  static String get _base => '$BASE_URL/api/categories';

  final _search = TextEditingController();
  String _filterType = "all";
  List<Map<String, dynamic>> activities = [];
  bool _loading = false;

  late AnimationController _fadeCtrl;
  late Animation<double>   _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 450));
    _fadeAnim =
        CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fetchCategories();
  }

  @override
  void dispose() {
    _search.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  // ── API ──────────────────────────────────────────────────
  Future<void> _fetchCategories() async {
    setState(() => _loading = true);
    _fadeCtrl.reset();
    try {
      final res = await http.get(Uri.parse(_base));
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        setState(() {
          activities = data
              .map((e) => {
                    'id':     e['id'],
                    'main':   e['main']   ?? '',
                    'title':  e['title']  ?? '',
                    'points': e['points'] ?? 0,
                    'type':   e['type']   ?? 'institute',
                    'status': e['status'] ?? 'active',
                  })
              .toList();
        });
        _fadeCtrl.forward();
      } else {
        _msg('Failed to load categories (${res.statusCode})');
      }
    } catch (e) {
      _msg('Network error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _addCategory(Map<String, dynamic> body) async {
    try {
      final res = await http.post(
        Uri.parse(_base),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        _msg('Category added');
        _fetchCategories();
      } else {
        _msg('Add failed (${res.statusCode})');
      }
    } catch (e) {
      _msg('Network error: $e');
    }
  }

  Future<void> _updateCategory(int id, Map<String, dynamic> body) async {
    try {
      final res = await http.put(
        Uri.parse('$_base/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      if (res.statusCode == 200) {
        _msg('Category updated');
        _fetchCategories();
      } else {
        _msg('Update failed (${res.statusCode})');
      }
    } catch (e) {
      _msg('Network error: $e');
    }
  }

  Future<void> _deleteCategory(int id) async {
    try {
      final res = await http.delete(Uri.parse('$_base/$id'));
      if (res.statusCode == 200 || res.statusCode == 204) {
        _msg('Category deleted');
        _fetchCategories();
      } else {
        _msg('Delete failed (${res.statusCode})');
      }
    } catch (e) {
      _msg('Network error: $e');
    }
  }

  // ── Helpers ──────────────────────────────────────────────
  void _msg(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text,
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

  List<Map<String, dynamic>> get _filtered {
    final q = _search.text.trim().toLowerCase();
    return activities.where((a) {
      final title = a["title"].toString().toLowerCase();
      final type  = a["type"].toString().toLowerCase();
      final matchSearch = q.isEmpty || title.contains(q);
      final matchType =
          _filterType == "all" ? true : type == _filterType;
      return matchSearch && matchType;
    }).toList();
  }

  List<String> _getMains(String type) => activities
      .where((a) => a['type'] == type)
      .map((a) => a['main'].toString())
      .where((m) => m.isNotEmpty)
      .toSet()
      .toList();

  // ── App-bar icon button ───────────────────────────────────
  Widget _appBarBtn(IconData icon, VoidCallback onTap,
          {EdgeInsets margin = const EdgeInsets.only(right: 4)}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
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

  // ── Shared input decoration ───────────────────────────────
  InputDecoration _inputDec(String hint, {IconData? prefix}) =>
      InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: _hint, fontSize: 13),
        filled: true,
        fillColor: _bg,
        prefixIcon:
            prefix != null ? Icon(prefix, color: _hint, size: 18) : null,
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

  // ══════════════════════════════════════════════════════════
  // ADD DIALOG
  // ══════════════════════════════════════════════════════════
  void _addDialog() {
    final titleCtrl   = TextEditingController();
    final pointsCtrl  = TextEditingController();
    final newMainCtrl = TextEditingController();
    String  type          = "institute";
    String? selectedMain;
    bool    createNewMain = false;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => Dialog(
          backgroundColor: _white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 46, height: 46,
                    decoration: BoxDecoration(
                      color: _navy,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.add_rounded,
                        color: _white, size: 24),
                  ),
                  const SizedBox(height: 14),
                  const Text("Add Category",
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: _navy)),
                  const SizedBox(height: 18),

                  // Title
                  TextField(
                    controller: titleCtrl,
                    cursorColor: _navy,
                    style: const TextStyle(color: _navy),
                    decoration: _inputDec("Activity title",
                        prefix: Icons.title_rounded),
                  ),
                  const SizedBox(height: 12),

                  // Points
                  TextField(
                    controller: pointsCtrl,
                    keyboardType: TextInputType.number,
                    cursorColor: _navy,
                    style: const TextStyle(color: _navy),
                    decoration: _inputDec("Points",
                        prefix: Icons.stars_rounded),
                  ),
                  const SizedBox(height: 12),

                  // Type
                  DropdownButtonFormField<String>(
                    value: type,
                    dropdownColor: _white,
                    style: const TextStyle(color: _navy, fontSize: 14),
                    decoration: _inputDec("Type"),
                    items: const [
                      DropdownMenuItem(
                          value: "institute",
                          child: Text("Institute")),
                      DropdownMenuItem(
                          value: "department",
                          child: Text("Department")),
                    ],
                    onChanged: (v) => setS(() {
                      type         = v!;
                      selectedMain = null;
                    }),
                  ),
                  const SizedBox(height: 12),

                  // Existing group
                  if (!createNewMain)
                    DropdownButtonFormField<String>(
                      value: selectedMain,
                      dropdownColor: _white,
                      style:
                          const TextStyle(color: _navy, fontSize: 14),
                      decoration: _inputDec("Select group"),
                      items: _getMains(type)
                          .map((e) => DropdownMenuItem(
                              value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) =>
                          setS(() => selectedMain = v),
                    ),

                  // New group toggle
                  Row(children: [
                    Checkbox(
                      value: createNewMain,
                      activeColor: _navy,
                      onChanged: (v) =>
                          setS(() => createNewMain = v ?? false),
                    ),
                    const Text("Create new group",
                        style: TextStyle(color: _muted, fontSize: 13)),
                  ]),
                  if (createNewMain) ...[
                    const SizedBox(height: 4),
                    TextField(
                      controller: newMainCtrl,
                      cursorColor: _navy,
                      style: const TextStyle(color: _navy),
                      decoration: _inputDec("New group name",
                          prefix: Icons.folder_outlined),
                    ),
                  ],

                  const SizedBox(height: 22),
                  Row(children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: TextButton.styleFrom(
                          foregroundColor: _muted,
                          padding: const EdgeInsets.symmetric(
                              vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: _border),
                          ),
                        ),
                        child: const Text("Cancel",
                            style: TextStyle(
                                fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _navy,
                          foregroundColor: _white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                              vertical: 13),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          final t =
                              titleCtrl.text.trim();
                          final pts = int.tryParse(
                              pointsCtrl.text.trim());
                          if (t.isEmpty || pts == null) {
                            _msg("Fill all fields");
                            return;
                          }
                          final mainName = createNewMain
                              ? newMainCtrl.text.trim()
                              : selectedMain;
                          if (mainName == null ||
                              mainName.isEmpty) {
                            _msg("Select or create a group");
                            return;
                          }
                          Navigator.pop(ctx);
                          _addCategory({
                            'main':   mainName,
                            'title':  t,
                            'points': pts,
                            'type':   type,
                            'status': 'active',
                          });
                        },
                        child: const Text("Add",
                            style: TextStyle(
                                fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // EDIT DIALOG
  // ══════════════════════════════════════════════════════════
  void _editDialog(int index) {
    final a           = activities[index];
    final titleCtrl   = TextEditingController(text: a["title"]);
    final pointsCtrl  =
        TextEditingController(text: a["points"].toString());

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
                  color: _amber.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.edit_rounded,
                    color: _amber, size: 22),
              ),
              const SizedBox(height: 14),
              const Text("Edit Category",
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: _navy)),
              const SizedBox(height: 6),
              Text(a["main"].toString(),
                  style:
                      const TextStyle(color: _muted, fontSize: 12)),
              const SizedBox(height: 18),
              TextField(
                controller: titleCtrl,
                cursorColor: _navy,
                style: const TextStyle(color: _navy),
                decoration: _inputDec("Activity title",
                    prefix: Icons.title_rounded),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: pointsCtrl,
                keyboardType: TextInputType.number,
                cursorColor: _navy,
                style: const TextStyle(color: _navy),
                decoration: _inputDec("Points",
                    prefix: Icons.stars_rounded),
              ),
              const SizedBox(height: 22),
              Row(children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: _muted,
                      padding:
                          const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: _border),
                      ),
                    ),
                    child: const Text("Cancel",
                        style:
                            TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _navy,
                      foregroundColor: _white,
                      elevation: 0,
                      padding:
                          const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      final t =
                          titleCtrl.text.trim();
                      final pts = int.tryParse(
                          pointsCtrl.text.trim());
                      if (t.isEmpty || pts == null) {
                        _msg("Invalid input");
                        return;
                      }
                      Navigator.pop(context);
                      _updateCategory(a['id'] as int, {
                        'main':   a['main'],
                        'title':  t,
                        'points': pts,
                        'type':   a['type'],
                        'status': a['status'],
                      });
                    },
                    child: const Text("Save",
                        style: TextStyle(
                            fontWeight: FontWeight.w700)),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // DELETE DIALOG
  // ══════════════════════════════════════════════════════════
  void _deleteDialog(int index) {
    final a = activities[index];
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
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.delete_rounded,
                    color: _red, size: 22),
              ),
              const SizedBox(height: 14),
              const Text("Delete Category",
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: _navy)),
              const SizedBox(height: 6),
              Text(
                'Are you sure you want to delete "${a["title"]}"?',
                style: const TextStyle(color: _muted, fontSize: 13),
              ),
              const SizedBox(height: 22),
              Row(children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: _muted,
                      padding:
                          const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: _border),
                      ),
                    ),
                    child: const Text("Cancel",
                        style:
                            TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _red,
                      foregroundColor: _white,
                      elevation: 0,
                      padding:
                          const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _deleteCategory(a['id'] as int);
                    },
                    child: const Text("Delete",
                        style: TextStyle(
                            fontWeight: FontWeight.w700)),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final list = _filtered;

    return Scaffold(
      backgroundColor: _bg,

      // ── APP BAR ────────────────────────────────────────
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
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.category_rounded,
                  color: _white, size: 18),
            ),
            const SizedBox(width: 10),
            const Text(
              "Categories",
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
          _appBarBtn(Icons.refresh_rounded, _fetchCategories),
          _appBarBtn(
            Icons.add_rounded,
            _addDialog,
            margin: const EdgeInsets.only(left: 4, right: 12),
          ),
        ],
      ),

      body: _loading
          ? _buildLoader()
          : Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                children: [

                  // ── SEARCH ──────────────────────────
                  TextField(
                    controller: _search,
                    onChanged: (_) => setState(() {}),
                    cursorColor: _navy,
                    style: const TextStyle(color: _navy, fontSize: 14),
                    decoration: _inputDec("Search categories…",
                        prefix: Icons.search_rounded),
                  ),

                  const SizedBox(height: 12),

                  // ── FILTER CHIPS ─────────────────────
                  Row(
                    children: [
                      _filterChip("All", "all"),
                      const SizedBox(width: 8),
                      _filterChip("Institute", "institute"),
                      const SizedBox(width: 8),
                      _filterChip("Department", "department"),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // ── COUNT ────────────────────────────
                  Row(
                    children: [
                      Text(
                        "${list.length} categor${list.length == 1 ? 'y' : 'ies'}",
                        style: const TextStyle(
                          color: _muted,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // ── LIST ─────────────────────────────
                  Expanded(
                    child: list.isEmpty
                        ? _buildEmpty()
                        : FadeTransition(
                            opacity: _fadeAnim,
                            child: ListView.builder(
                              physics:
                                  const BouncingScrollPhysics(),
                              itemCount: list.length,
                              itemBuilder: (ctx, i) {
                                final a = list[i];
                                final realIdx =
                                    activities.indexOf(a);
                                return _CategoryTile(
                                  item: a,
                                  index: i,
                                  onEdit: () =>
                                      _editDialog(realIdx),
                                  onDelete: () =>
                                      _deleteDialog(realIdx),
                                );
                              },
                            ),
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _filterChip(String label, String value) {
    final active = _filterType == value;
    return GestureDetector(
      onTap: () => setState(() => _filterType = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: active ? _navy : _white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: active ? _navy : _border),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: _navy.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? _white : _muted,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildLoader() => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 44, height: 44,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(_navy),
                backgroundColor: _border,
              ),
            ),
            const SizedBox(height: 14),
            const Text("Loading categories…",
                style: TextStyle(color: _muted, fontSize: 13)),
          ],
        ),
      );

  Widget _buildEmpty() => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                color: _white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: _border),
              ),
              child: const Icon(Icons.category_outlined,
                  color: _hint, size: 34),
            ),
            const SizedBox(height: 16),
            const Text("No categories found",
                style: TextStyle(
                    color: _navy,
                    fontSize: 15,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            const Text("Try a different search or filter.",
                style: TextStyle(color: _muted, fontSize: 13)),
          ],
        ),
      );
}

// ══════════════════════════════════════════════════════════
// CATEGORY TILE
// ══════════════════════════════════════════════════════════
class _CategoryTile extends StatefulWidget {
  final Map<String, dynamic> item;
  final int          index;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CategoryTile({
    required this.item,
    required this.index,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_CategoryTile> createState() => _CategoryTileState();
}

class _CategoryTileState extends State<_CategoryTile>
    with SingleTickerProviderStateMixin {

  static const _navy   = Color(0xFF03305A);
  static const _white  = Colors.white;
  static const _border = Color(0xFFD8E3ED);
  static const _muted  = Color(0xFF6B7C93);
  static const _hint   = Color(0xFFAAB8C5);
  static const _amber  = Color(0xFFF59E0B);
  static const _bg     = Color(0xFFF5F7FA);

  late AnimationController _ctrl;
  late Animation<double>   _slide;
  late Animation<double>   _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 320 + widget.index * 35),
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

  @override
  Widget build(BuildContext context) {
    final a           = widget.item;
    final isInstitute = a["type"]?.toString() == "institute";

    // Icon + colour based on type
    final iconBg    = isInstitute
        ? _navy.withOpacity(0.08)
        : _amber.withOpacity(0.12);
    final iconColor = isInstitute ? _navy : _amber;
    final icon      = isInstitute
        ? Icons.apartment_rounded
        : Icons.school_rounded;

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) => Opacity(
        opacity: _fade.value,
        child: Transform.translate(
            offset: Offset(0, _slide.value), child: child),
      ),
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
            // Icon box
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),

            // Title + group + type
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    a["title"].toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: _navy,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    a["main"].toString(),
                    style: const TextStyle(
                        fontSize: 11, color: _muted),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      // Type chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: iconBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isInstitute
                              ? "Institute"
                              : "Department",
                          style: TextStyle(
                            color: iconColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Points chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: _bg,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: _border),
                        ),
                        child: Text(
                          "${a["points"]} pts",
                          style: const TextStyle(
                            color: _navy,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Action menu
            PopupMenuButton<String>(
              icon: Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: _bg,
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(color: _border),
                ),
                child: const Icon(Icons.more_vert_rounded,
                    size: 16, color: _hint),
              ),
              color: _white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: 4,
              onSelected: (val) {
                if (val == "edit") {
                  widget.onEdit();
                } else {
                  widget.onDelete();
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: "edit",
                  child: Row(children: const [
                    Icon(Icons.edit_rounded,
                        size: 16, color: _navy),
                    SizedBox(width: 8),
                    Text("Edit",
                        style: TextStyle(
                            color: _navy,
                            fontWeight: FontWeight.w600)),
                  ]),
                ),
                PopupMenuItem(
                  value: "delete",
                  child: Row(children: const [
                    Icon(Icons.delete_rounded,
                        size: 16, color: Color(0xFFE24B4A)),
                    SizedBox(width: 8),
                    Text("Delete",
                        style: TextStyle(
                            color: Color(0xFFE24B4A),
                            fontWeight: FontWeight.w600)),
                  ]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
