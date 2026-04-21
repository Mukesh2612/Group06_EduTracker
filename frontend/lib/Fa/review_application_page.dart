import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../config/api.dart';

// ══════════════════════════════════════════════════════════
// REVIEW APPLICATION PAGE
// ══════════════════════════════════════════════════════════
class ReviewApplicationPage extends StatefulWidget {
  final int?    faId;
  final int?    submissionId;
  final String? highlightStudent;

  const ReviewApplicationPage({
    super.key,
    this.faId,
    this.submissionId,
    this.highlightStudent,
  });

  @override
  State<ReviewApplicationPage> createState() => _ReviewApplicationPageState();
}

class _ReviewApplicationPageState extends State<ReviewApplicationPage>
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
  static const _blue   = Color(0xFF2563EB);

  final baseUrl = BASE_URL;

  List<Map<String, dynamic>> requests = [];
  bool isLoading = true;

  final Map<int, TextEditingController> remarkControllers = {};
  final ScrollController                _scrollCtrl       = ScrollController();
  final Map<int, GlobalKey>             _cardKeys         = {};

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
    fetchPending();
  }

  @override
  void dispose() {
    for (final c in remarkControllers.values) c.dispose();
    _scrollCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  dynamic _get(Map<String, dynamic> map, String key) =>
      map.containsKey(key) ? map[key] : map[key.toLowerCase()];

  // ── Fetch pending ────────────────────────────────────────
  Future<void> fetchPending() async {
    setState(() => isLoading = true);
    _fadeCtrl.reset();
    try {
      final res = await http
          .get(Uri.parse("$baseUrl/api/submissions/pending"))
          .timeout(const Duration(seconds: 15));

      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        setState(() {
          requests  = data.map((e) => Map<String, dynamic>.from(e)).toList();
          isLoading = false;
        });
        _fadeCtrl.forward();

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (widget.highlightStudent != null) {
            _scrollToStudent(widget.highlightStudent!);
          }
          if (widget.submissionId != null) {
            _scrollToSubmission(widget.submissionId!);
          }
        });
      } else {
        msg("Failed to load requests (${res.statusCode})");
        setState(() => isLoading = false);
      }
    } on TimeoutException {
      msg("Server not responding. Check your connection.");
      setState(() => isLoading = false);
    } catch (e) {
      msg("Network error: $e");
      setState(() => isLoading = false);
    }
  }

  void _scrollToSubmission(int submissionId) {
    for (int i = 0; i < requests.length; i++) {
      final id = (_get(requests[i], 'id') ?? -1) as int;
      if (id == submissionId) {
        final key = _cardKeys[i];
        if (key?.currentContext != null) {
          Scrollable.ensureVisible(key!.currentContext!,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              alignment: 0.1);
        }
        break;
      }
    }
  }

  void _scrollToStudent(String studentName) {
    for (int i = 0; i < requests.length; i++) {
      final name = (_get(requests[i], 'studentName') ?? '').toString();
      if (name.toLowerCase().contains(studentName.toLowerCase())) {
        final key = _cardKeys[i];
        if (key?.currentContext != null) {
          Scrollable.ensureVisible(key!.currentContext!,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              alignment: 0.1);
        }
        break;
      }
    }
  }

  // ── Approve ──────────────────────────────────────────────
  Future<void> approveRequest(int index) async {
    final id = _get(requests[index], 'id');
    try {
      final res = await http
          .put(Uri.parse("$baseUrl/api/submissions/approve/$id"))
          .timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) {
        msg("Approved — points added to student");
        setState(() => requests.removeAt(index));
      } else {
        msg("Approval failed (${res.statusCode})");
      }
    } on TimeoutException {
      msg("Request timed out.");
    } catch (e) {
      msg("Network error: $e");
    }
  }

  // ── Reject ───────────────────────────────────────────────
  Future<void> rejectRequest(int index) async {
    final id     = _get(requests[index], 'id');
    final remark = remarkControllers[id]?.text ?? "";
    try {
      final res = await http
          .put(
            Uri.parse("$baseUrl/api/submissions/reject/$id"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"remarks": remark}),
          )
          .timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) {
        msg("Rejected");
        setState(() => requests.removeAt(index));
      } else {
        msg("Rejection failed (${res.statusCode})");
      }
    } on TimeoutException {
      msg("Request timed out.");
    } catch (e) {
      msg("Network error: $e");
    }
  }

  Future<void> openProofFile(String? fileName) async {
    if (fileName == null || fileName.trim().isEmpty) {
      msg("No proof file attached");
      return;
    }
    final url = Uri.parse("$baseUrl/uploads/${fileName.trim()}");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      msg("Could not open file");
    }
  }

  void msg(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text,
            style: const TextStyle(
                color: _white, fontWeight: FontWeight.w600)),
        backgroundColor: _navy,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
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
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _navy,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.rate_review_rounded,
                  color: _white, size: 18),
            ),
            const SizedBox(width: 10),
            const Text(
              "Review Applications",
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
            onTap: fetchPending,
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

      // ── BODY ─────────────────────────────────────────────
      body: isLoading
          ? _buildLoader()
          : requests.isEmpty
              ? _buildEmpty()
              : FadeTransition(
                  opacity: _fadeAnim,
                  child: ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      final r           = requests[index];
                      final int id      = (_get(r, 'id') ?? index) as int;
                      final studentName =
                          (_get(r, 'studentName') ?? '').toString();

                      remarkControllers.putIfAbsent(
                          id, () => TextEditingController());
                      _cardKeys.putIfAbsent(index, () => GlobalKey());

                      final bool isHighlighted =
                          (widget.submissionId != null &&
                                  id == widget.submissionId) ||
                              (widget.highlightStudent != null &&
                                  studentName.toLowerCase().contains(
                                      widget.highlightStudent!.toLowerCase()));

                      return _ReviewCard(
                        key: _cardKeys[index],
                        index: index,
                        r: r,
                        id: id,
                        studentName: studentName,
                        isHighlighted: isHighlighted,
                        remarkController: remarkControllers[id]!,
                        onApprove: () => approveRequest(index),
                        onReject: () => rejectRequest(index),
                        onOpenFile: () => openProofFile(
                            (_get(r, 'proofFile') ?? '').toString()),
                        getter: _get,
                        initials: _initials,
                      );
                    },
                  ),
                ),
    );
  }

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
            const Text("Loading applications…",
                style: TextStyle(color: _muted, fontSize: 13)),
          ],
        ),
      );

  Widget _buildEmpty() => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: _white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: _border),
                boxShadow: [
                  BoxShadow(
                    color: _navy.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.check_circle_outline_rounded,
                  color: _hint, size: 34),
            ),
            const SizedBox(height: 16),
            const Text("All caught up!",
                style: TextStyle(
                    color: _navy,
                    fontSize: 15,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            const Text("No pending applications to review.",
                style: TextStyle(color: _muted, fontSize: 13)),
          ],
        ),
      );
}

// ══════════════════════════════════════════════════════════
// REVIEW CARD
// ══════════════════════════════════════════════════════════
class _ReviewCard extends StatefulWidget {
  final int   index;
  final Map<String, dynamic> r;
  final int    id;
  final String studentName;
  final bool   isHighlighted;
  final TextEditingController remarkController;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onOpenFile;
  final dynamic Function(Map<String, dynamic>, String) getter;
  final String Function(String) initials;

  const _ReviewCard({
    super.key,
    required this.index,
    required this.r,
    required this.id,
    required this.studentName,
    required this.isHighlighted,
    required this.remarkController,
    required this.onApprove,
    required this.onReject,
    required this.onOpenFile,
    required this.getter,
    required this.initials,
  });

  @override
  State<_ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<_ReviewCard>
    with SingleTickerProviderStateMixin {

  static const _bg     = Color(0xFFF5F7FA);
  static const _navy   = Color(0xFF03305A);
  static const _white  = Colors.white;
  static const _border = Color(0xFFD8E3ED);
  static const _muted  = Color(0xFF6B7C93);
  static const _hint   = Color(0xFFAAB8C5);
  static const _green  = Color(0xFF1D9E75);
  static const _red    = Color(0xFFE24B4A);
  static const _blue   = Color(0xFF2563EB);

  late AnimationController _ctrl;
  late Animation<double>   _slide;
  late Animation<double>   _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 350 + widget.index * 50),
    );
    _slide = Tween<double>(begin: 28, end: 0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _fade = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    Future.delayed(Duration(milliseconds: widget.index * 60), () {
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
    final r           = widget.r;
    final g           = widget.getter;
    final highlighted = widget.isHighlighted;

    final title    = (g(r, 'title')    ?? '—').toString();
    final rollNo   = (g(r, 'rollNo')   ?? '—').toString();
    final category = (g(r, 'category') ?? '—').toString();
    final points   = (g(r, 'points')   ?? '—').toString();
    final proof    = (g(r, 'proofFile') ?? '').toString();

    // Rotating avatar color pairs
    final avatarBgs = [
      const Color(0xFFDCEAF8),
      const Color(0xFFD1F0E5),
      const Color(0xFFFDE8D0),
      const Color(0xFFEDE1F8),
    ];
    final avatarFgs = [
      _navy,
      _green,
      const Color(0xFFF59E0B),
      const Color(0xFF7C3AED),
    ];
    final ci = widget.index % avatarBgs.length;

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) => Opacity(
        opacity: _fade.value,
        child: Transform.translate(
            offset: Offset(0, _slide.value), child: child),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: _white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: highlighted ? _blue.withOpacity(0.5) : _border,
            width: highlighted ? 1.8 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: highlighted
                  ? _blue.withOpacity(0.1)
                  : _navy.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── NEW badge ────────────────────────────
              if (highlighted) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _blue.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: _blue.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.notifications_rounded,
                          color: _blue, size: 13),
                      SizedBox(width: 5),
                      Text("New Submission",
                          style: TextStyle(
                              color: _blue,
                              fontWeight: FontWeight.w700,
                              fontSize: 11)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // ── Student info row ─────────────────────
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: avatarBgs[ci],
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        widget.initials(widget.studentName),
                        style: TextStyle(
                          color: avatarFgs[ci],
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.studentName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: _navy,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          rollNo,
                          style: const TextStyle(
                              fontSize: 12, color: _muted),
                        ),
                      ],
                    ),
                  ),
                  // Points badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _navy.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(
                          color: _navy.withOpacity(0.15)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.stars_rounded,
                            size: 13, color: _navy),
                        const SizedBox(width: 4),
                        Text(
                          "$points pts",
                          style: const TextStyle(
                            color: _navy,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),
              Divider(color: _border, height: 1),
              const SizedBox(height: 12),

              // ── Activity details ─────────────────────
              _detailRow(Icons.title_rounded, "Title", title),
              const SizedBox(height: 8),
              _detailRow(
                  Icons.bookmarks_rounded, "Category", category),

              const SizedBox(height: 14),

              // ── Proof file button ─────────────────────
              GestureDetector(
                onTap: widget.onOpenFile,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: _blue.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: _blue.withOpacity(0.25)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: _blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.open_in_new_rounded,
                            color: _blue, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "View Proof Document",
                              style: TextStyle(
                                color: _blue,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              proof.isNotEmpty ? proof : "No file attached",
                              style: const TextStyle(
                                  color: _muted, fontSize: 11),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded,
                          color: _hint, size: 18),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ── Remarks field ─────────────────────────
              TextField(
                controller: widget.remarkController,
                maxLines: 2,
                cursorColor: _navy,
                style: const TextStyle(
                    color: _navy, fontSize: 13),
                decoration: InputDecoration(
                  hintText: "Add remarks (optional for rejection)",
                  hintStyle: const TextStyle(
                      color: _hint, fontSize: 13),
                  filled: true,
                  fillColor: _bg,
                  prefixIcon: const Icon(Icons.comment_rounded,
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

              const SizedBox(height: 14),

              // ── Approve / Reject buttons ──────────────
              Row(
                children: [
                  Expanded(
                    child: _ActionBtn(
                      label: "Approve",
                      icon: Icons.check_circle_rounded,
                      color: _green,
                      onTap: widget.onApprove,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ActionBtn(
                      label: "Reject",
                      icon: Icons.cancel_rounded,
                      color: _red,
                      onTap: widget.onReject,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: _hint),
          const SizedBox(width: 6),
          Text("$label: ",
              style: const TextStyle(
                  color: _muted, fontSize: 12)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: _navy,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
}

// ══════════════════════════════════════════════════════════
// ACTION BUTTON (press scale animation)
// ══════════════════════════════════════════════════════════
class _ActionBtn extends StatefulWidget {
  final String     label;
  final IconData   icon;
  final Color      color;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<_ActionBtn> createState() => _ActionBtnState();
}

class _ActionBtnState extends State<_ActionBtn> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 110),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(13),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.28),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: Colors.white, size: 18),
              const SizedBox(width: 7),
              Text(
                widget.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
