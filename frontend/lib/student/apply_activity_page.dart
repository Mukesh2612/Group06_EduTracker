import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../config/api.dart';

// ══════════════════════════════════════════════════════════
// APPLY ACTIVITY SCREEN
// ══════════════════════════════════════════════════════════
class ApplyActivityScreen extends StatefulWidget {
  final int studentId;

  const ApplyActivityScreen({super.key, required this.studentId});

  @override
  State<ApplyActivityScreen> createState() => _ApplyActivityScreenState();
}

class _ApplyActivityScreenState extends State<ApplyActivityScreen>
    with SingleTickerProviderStateMixin {

  // ── Design tokens ────────────────────────────────────────
  static const _bg     = Color(0xFFF5F7FA);
  static const _navy   = Color(0xFF03305A);
  static const _white  = Colors.white;
  static const _border = Color(0xFFD8E3ED);
  static const _muted  = Color(0xFF6B7C93);
  static const _hint   = Color(0xFFAAB8C5);
  static const _green  = Color(0xFF1D9E75);
  static const _red    = Color(0xFFE24B4A);
  static const _amber  = Color(0xFFF59E0B);

  static String get _baseUrl => BASE_URL;

  // ── Form state ───────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  final TextEditingController titleController = TextEditingController();

  String?    selectedFilePath;
  Uint8List? selectedFileBytes;
  String?    selectedLevel;
  String?    selectedGroup;
  String?    selectedCategory;
  String?    fileName;
  int?       points;
  bool       _isSubmitting      = false;
  bool       _loadingCategories = true;

  List<Map<String, dynamic>> _allCategories = [];

  // ── Entrance animation ───────────────────────────────────
  late AnimationController _fadeCtrl;
  late Animation<double>   _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fetchCategories();
  }

  @override
  void dispose() {
    titleController.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  // ── API: fetch categories ────────────────────────────────
  Future<void> _fetchCategories() async {
    setState(() => _loadingCategories = true);
    _fadeCtrl.reset();
    try {
      final res = await http
          .get(Uri.parse("$_baseUrl/api/categories"))
          .timeout(const Duration(seconds: 15));

      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        setState(() {
          _allCategories = data
              .where((e) =>
                  (e['status'] ?? '').toString().toLowerCase() == 'active')
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
        msg("Failed to load categories (${res.statusCode})");
      }
    } on TimeoutException {
      msg("Server not responding. Check connection.");
    } catch (e) {
      msg("Error loading categories: $e");
    } finally {
      setState(() => _loadingCategories = false);
    }
  }

  // ── API: upload file ─────────────────────────────────────
  Future<String?> uploadFile() async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse("$_baseUrl/api/upload"),
    );
    if (selectedFileBytes != null) {
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        selectedFileBytes!,
        filename: fileName ?? 'upload',
      ));
    } else if (selectedFilePath != null) {
      request.files.add(
          await http.MultipartFile.fromPath('file', selectedFilePath!));
    } else {
      return null;
    }
    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['fileName'];
      }
      return null;
    } catch (e) {
      debugPrint("Upload Error: $e");
      return null;
    }
  }

  // ── Helpers ──────────────────────────────────────────────
  void msg(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text,
            style: const TextStyle(
                color: _white, fontWeight: FontWeight.w600)),
        backgroundColor: _navy,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> pickProofFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png'],
      withData: true,
    );
    if (result != null) {
      setState(() {
        fileName          = result.files.single.name;
        selectedFileBytes = result.files.single.bytes;
        selectedFilePath  = result.files.single.path;
      });
    }
  }

  void resetForm() {
    titleController.clear();
    setState(() {
      selectedFilePath  = null;
      selectedFileBytes = null;
      selectedLevel     = null;
      selectedGroup     = null;
      selectedCategory  = null;
      points            = null;
      fileName          = null;
    });
  }

  List<String> get groupList {
    if (selectedLevel == null) return [];
    final typeKey =
        selectedLevel == "Institute Level" ? "institute" : "department";
    return _allCategories
        .where((c) => c['type'] == typeKey)
        .map((c) => c['main'].toString())
        .where((m) => m.isNotEmpty)
        .toSet()
        .toList();
  }

  List<Map<String, dynamic>> get categoryList {
    if (selectedLevel == null || selectedGroup == null) return [];
    final typeKey =
        selectedLevel == "Institute Level" ? "institute" : "department";
    return _allCategories
        .where((c) => c['type'] == typeKey && c['main'] == selectedGroup)
        .toList();
  }

  // ── Shared input decoration ──────────────────────────────
  InputDecoration _fieldStyle(String label, {IconData? prefixIcon}) =>
      InputDecoration(
        labelText: label,
        labelStyle:
            const TextStyle(color: _muted, fontWeight: FontWeight.w600),
        hintStyle: const TextStyle(color: _hint),
        filled: true,
        fillColor: _bg,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: _navy, size: 20)
            : null,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _navy, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _red, width: 1.5),
        ),
      );

  // ── Section card wrapper ─────────────────────────────────
  Widget _sectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: _navy.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: _navy.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: _navy, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: _navy,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: _border, height: 1),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  // ── Step indicator row ───────────────────────────────────
  Widget _stepRow(int step, String label, bool done) {
    return Row(
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: done ? _green : _navy.withOpacity(0.08),
            shape: BoxShape.circle,
            border: Border.all(
              color: done ? _green : _border,
            ),
          ),
          child: Center(
            child: done
                ? const Icon(Icons.check_rounded,
                    color: _white, size: 14)
                : Text(
                    "$step",
                    style: TextStyle(
                      color: done ? _white : _navy,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: done ? _green : _muted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final step1done = selectedLevel != null;
    final step2done = selectedGroup != null;
    final step3done = selectedCategory != null;
    final step4done = fileName != null;

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
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _navy,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.add_task_rounded,
                  color: _white, size: 18),
            ),
            const SizedBox(width: 10),
            const Text(
              "Apply Activity Points",
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
          GestureDetector(
            onTap: _fetchCategories,
            child: Container(
              width: 40,
              height: 40,
              margin: const EdgeInsets.only(right: 12),
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
              child: const Icon(Icons.refresh_rounded,
                  color: _navy, size: 20),
            ),
          ),
        ],
      ),

      // ── BODY ───────────────────────────────────────────
      body: _loadingCategories
          ? _buildLoader()
          : FadeTransition(
              opacity: _fadeAnim,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [

                      // ── PROGRESS STEPS ──────────────────
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF03305A), Color(0xFF1A5C94)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: _navy.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Application Steps",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                    child: _whiteStep(
                                        1, "Level", step1done)),
                                _stepDivider(step1done),
                                Expanded(
                                    child: _whiteStep(
                                        2, "Group", step2done)),
                                _stepDivider(step2done),
                                Expanded(
                                    child: _whiteStep(
                                        3, "Category", step3done)),
                                _stepDivider(step3done),
                                Expanded(
                                    child: _whiteStep(
                                        4, "Proof", step4done)),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // ── ACTIVITY DETAILS CARD ────────────
                      _sectionCard(
                        title: "Activity Details",
                        icon: Icons.edit_note_rounded,
                        children: [

                          // Title
                          TextFormField(
                            controller: titleController,
                            style: const TextStyle(
                                color: _navy, fontWeight: FontWeight.w600),
                            cursorColor: _navy,
                            decoration: _fieldStyle(
                              "Activity Title",
                              prefixIcon: Icons.title_rounded,
                            ),
                            validator: (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? "Enter activity title"
                                    : null,
                          ),

                          const SizedBox(height: 14),

                          // Level dropdown
                          DropdownButtonFormField<String>(
                            value: selectedLevel,
                            decoration: _fieldStyle(
                              "Select Level",
                              prefixIcon: Icons.layers_rounded,
                            ),
                            dropdownColor: _white,
                            style: const TextStyle(
                                color: _navy, fontWeight: FontWeight.w600),
                            items: const [
                              DropdownMenuItem(
                                value: "Department Level",
                                child: Text("Department Level"),
                              ),
                              DropdownMenuItem(
                                value: "Institute Level",
                                child: Text("Institute Level"),
                              ),
                            ],
                            validator: (v) =>
                                v == null ? "Select level" : null,
                            onChanged: (v) {
                              setState(() {
                                selectedLevel    = v;
                                selectedGroup    = null;
                                selectedCategory = null;
                                points           = null;
                              });
                            },
                          ),

                          // Group dropdown
                          if (selectedLevel != null) ...[
                            const SizedBox(height: 14),
                            DropdownButtonFormField<String>(
                              value: selectedGroup,
                              decoration: _fieldStyle(
                                "Select Group",
                                prefixIcon: Icons.category_rounded,
                              ),
                              dropdownColor: _white,
                              style: const TextStyle(
                                  color: _navy, fontWeight: FontWeight.w600),
                              items: groupList
                                  .map((g) => DropdownMenuItem(
                                      value: g, child: Text(g)))
                                  .toList(),
                              validator: (v) =>
                                  v == null ? "Select group" : null,
                              onChanged: (v) {
                                setState(() {
                                  selectedGroup    = v;
                                  selectedCategory = null;
                                  points           = null;
                                });
                              },
                            ),
                          ],

                          // Category dropdown
                          if (selectedGroup != null) ...[
                            const SizedBox(height: 14),
                            DropdownButtonFormField<String>(
                              value: selectedCategory,
                              decoration: _fieldStyle(
                                "Select Category",
                                prefixIcon: Icons.bookmarks_rounded,
                              ),
                              dropdownColor: _white,
                              style: const TextStyle(
                                  color: _navy, fontWeight: FontWeight.w600),
                              items: categoryList.isEmpty
                                  ? [
                                      const DropdownMenuItem(
                                        value: null,
                                        child: Text(
                                          "No categories available",
                                          style:
                                              TextStyle(color: _hint),
                                        ),
                                      )
                                    ]
                                  : categoryList
                                      .map((c) => DropdownMenuItem<String>(
                                            value: c['id'].toString(),
                                            child: Text(c['title']),
                                          ))
                                      .toList(),
                              validator: (v) =>
                                  v == null ? "Select category" : null,
                              onChanged: categoryList.isEmpty
                                  ? null
                                  : (v) {
                                      setState(() {
                                        selectedCategory = v;
                                        final match = categoryList
                                            .firstWhere(
                                              (c) =>
                                                  c['id'].toString() == v,
                                              orElse: () => {},
                                            );
                                        points = match.isNotEmpty
                                            ? match['points'] as int
                                            : null;
                                      });
                                    },
                            ),
                          ],

                          // Points display
                          if (points != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: _green.withOpacity(0.07),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: _green.withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: _green.withOpacity(0.15),
                                      borderRadius:
                                          BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                        Icons.stars_rounded,
                                        color: _green,
                                        size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Points for this activity",
                                          style: TextStyle(
                                            color: _muted,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    "$points pts",
                                    style: const TextStyle(
                                      color: _green,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),

                      const SizedBox(height: 14),

                      // ── FILE UPLOAD CARD ─────────────────
                      _sectionCard(
                        title: "Proof Document",
                        icon: Icons.attach_file_rounded,
                        children: [
                          GestureDetector(
                            onTap: pickProofFile,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: double.infinity,
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: fileName != null
                                    ? _green.withOpacity(0.06)
                                    : _bg,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: fileName != null
                                      ? _green.withOpacity(0.4)
                                      : _border,
                                  width: fileName != null ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: fileName != null
                                          ? _green.withOpacity(0.12)
                                          : _navy.withOpacity(0.07),
                                      borderRadius:
                                          BorderRadius.circular(14),
                                    ),
                                    child: Icon(
                                      fileName != null
                                          ? Icons.check_circle_rounded
                                          : Icons.upload_file_rounded,
                                      color: fileName != null
                                          ? _green
                                          : _navy,
                                      size: 26,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          fileName != null
                                              ? fileName!
                                              : "Tap to upload proof",
                                          style: TextStyle(
                                            color: fileName != null
                                                ? _green
                                                : _navy,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          fileName != null
                                              ? "File attached ✓"
                                              : "PDF, JPG or PNG accepted",
                                          style: TextStyle(
                                            color: fileName != null
                                                ? _green.withOpacity(0.7)
                                                : _hint,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_right_rounded,
                                    color: fileName != null
                                        ? _green
                                        : _hint,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),

                      // ── SUBMIT BUTTON ────────────────────
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _navy,
                            foregroundColor: _white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            shadowColor: _navy.withOpacity(0.3),
                          ),
                          onPressed: _isSubmitting ? null : _submit,
                          child: _isSubmitting
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    color: _white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.send_rounded, size: 20),
                                    SizedBox(width: 10),
                                    Text(
                                      "Submit Application",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        "EduTracker",
                        style: TextStyle(
                          color: _hint,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  // ── White step chip (inside navy card) ──────────────────
  Widget _whiteStep(int step, String label, bool done) {
    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: done
                ? const Color(0xFF6EEAC8)
                : _white.withOpacity(0.18),
            shape: BoxShape.circle,
            border: Border.all(
              color: done
                  ? const Color(0xFF6EEAC8)
                  : _white.withOpacity(0.3),
            ),
          ),
          child: Center(
            child: done
                ? const Icon(Icons.check_rounded,
                    color: _navy, size: 14)
                : Text(
                    "$step",
                    style: TextStyle(
                      color: _white.withOpacity(0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          softWrap: false,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: done
                ? const Color(0xFF6EEAC8)
                : _white.withOpacity(0.65),
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _stepDivider(bool done) => Expanded(
        child: Container(
          height: 1.5,
          margin: const EdgeInsets.only(bottom: 16),
          color: done
              ? const Color(0xFF6EEAC8).withOpacity(0.5)
              : _white.withOpacity(0.2),
        ),
      );

  Widget _buildLoader() => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 44,
              height: 44,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(_navy),
                backgroundColor: _border,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              "Loading categories…",
              style: TextStyle(color: _muted, fontSize: 13),
            ),
          ],
        ),
      );

  // ── Submit logic (extracted) ─────────────────────────────
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (fileName == null ||
        (selectedFileBytes == null && selectedFilePath == null)) {
      msg("Please upload proof");
      return;
    }

    setState(() => _isSubmitting = true);

    final uploadedFile = await uploadFile();
    if (uploadedFile == null || uploadedFile.trim().isEmpty) {
      msg("Upload failed. Please try again.");
      setState(() => _isSubmitting = false);
      return;
    }

    final selectedCat = categoryList.firstWhere(
      (c) => c['id'].toString() == selectedCategory,
      orElse: () => {},
    );

    try {
      final response = await http
          .post(
            Uri.parse("$_baseUrl/api/submissions/submit"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "studentId":     widget.studentId,
              "title":         titleController.text.trim(),
              "level":         selectedLevel,
              "activityGroup": selectedGroup,
              "category":      selectedCat['title'] ?? '',
              "categoryId":    selectedCat['id'],
              "points":        points,
              "proofFile":     uploadedFile.trim(),
              "status":        "PENDING",
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        msg("Application sent to FA ✅");
        resetForm();
      } else {
        msg("Submission failed (${response.statusCode})");
      }
    } on TimeoutException {
      msg("Server not responding. Try again.");
    } catch (e) {
      msg("Error: $e");
    } finally {
      setState(() => _isSubmitting = false);
    }
  }
}
