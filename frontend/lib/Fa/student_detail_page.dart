import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../config/api.dart';

// ══════════════════════════════════════════════════════════
// STUDENT DETAIL PAGE  (FA view)
// ══════════════════════════════════════════════════════════
class StudentDetailPage extends StatefulWidget {
  final Map student; // basic data already loaded from FA dashboard list

  const StudentDetailPage({super.key, required this.student});

  @override
  State<StudentDetailPage> createState() => _StudentDetailPageState();
}

class _StudentDetailPageState extends State<StudentDetailPage>
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

  // ── State ────────────────────────────────────────────────
  Map<String, dynamic>? profile;
  List submissions = [];
  bool loadingProfile     = true;
  bool loadingSubmissions = true;

  late AnimationController _fadeCtrl;
  late Animation<double>   _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 450));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _loadData();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final email     = widget.student["email"] ?? "";
    final studentId = widget.student["id"];

    await Future.wait([
      _fetchProfile(email),
      _fetchSubmissions(studentId),
    ]);

    if (mounted) _fadeCtrl.forward();
  }

  Future<void> _fetchProfile(String email) async {
    try {
      final res = await http
          .get(Uri.parse("$BASE_URL/auth/student/profile/$email"))
          .timeout(const Duration(seconds: 15));
      if (res.statusCode == 200 && mounted) {
        setState(() {
          profile = Map<String, dynamic>.from(jsonDecode(res.body));
          loadingProfile = false;
        });
      } else {
        if (mounted) setState(() => loadingProfile = false);
      }
    } catch (_) {
      if (mounted) setState(() => loadingProfile = false);
    }
  }

  Future<void> _fetchSubmissions(dynamic studentId) async {
    if (studentId == null) {
      if (mounted) setState(() => loadingSubmissions = false);
      return;
    }
    try {
      final res = await http
          .get(Uri.parse("$BASE_URL/api/submissions/student/$studentId"))
          .timeout(const Duration(seconds: 15));
      if (res.statusCode == 200 && mounted) {
        setState(() {
          submissions = jsonDecode(res.body);
          loadingSubmissions = false;
        });
      } else {
        if (mounted) setState(() => loadingSubmissions = false);
      }
    } catch (_) {
      if (mounted) setState(() => loadingSubmissions = false);
    }
  }

  // ── Status helpers ───────────────────────────────────────
  Color _statusColor(String s) {
    switch (s) {
      case "APPROVED": return _green;
      case "REJECTED": return _red;
      default:          return _amber;
    }
  }

  IconData _statusIcon(String s) {
    switch (s) {
      case "APPROVED": return Icons.check_circle_rounded;
      case "REJECTED": return Icons.cancel_rounded;
      default:          return Icons.hourglass_top_rounded;
    }
  }

  String _statusLabel(String s) {
    switch (s) {
      case "APPROVED": return "Approved";
      case "REJECTED": return "Rejected";
      default:          return "Pending";
    }
  }

  // ── Snackbar ─────────────────────────────────────────────
  void _snack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg,
            style: const TextStyle(
                color: _white, fontWeight: FontWeight.w600)),
        backgroundColor: isError ? _red : _navy,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ── Open proof document ──────────────────────────────────
  Future<void> _openDoc(String? proofFile) async {
    if (proofFile == null || proofFile.isEmpty) {
      _snack("No document attached.", isError: true);
      return;
    }
    final uri = Uri.parse("$BASE_URL/uploads/$proofFile");
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _snack("Cannot open document — no app available.", isError: true);
      }
    } catch (e) {
      _snack("Error: $e", isError: true);
    }
  }

  // ── Quick computed stats ─────────────────────────────────
  int get _totalSubs    => submissions.length;
  int get _approvedSubs =>
      submissions.where((s) => s["status"] == "APPROVED").length;
  int get _pendingSubs  =>
      submissions.where((s) => s["status"] == "PENDING").length;
  int get _rejectedSubs =>
      submissions.where((s) => s["status"] == "REJECTED").length;

  // ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final s      = widget.student;
    final name   = s["name"]   ?? "Student";
    final email  = s["email"]  ?? "—";
    final dept   = s["dept"]   ?? "—";
    final rollNo = s["rollNo"] ?? "—";
    final points = s["points"] ?? 0;

    // Merge profile data once loaded
    final p = profile;
    final faName  = p?["faName"]  ?? "—";
    final faEmail = p?["faEmail"] ?? "—";

    final initials = name.trim().split(" ").take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : "")
        .join();

    final isLoading = loadingProfile || loadingSubmissions;

    return Scaffold(
      backgroundColor: _bg,
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
                  color: _navy, borderRadius: BorderRadius.circular(10)),
              child:
                  const Icon(Icons.person_rounded, color: _white, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  color: _navy,
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                  letterSpacing: -0.3,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: isLoading
          ? _buildLoader()
          : FadeTransition(
              opacity: _fadeAnim,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                children: [

                  // ── HERO BANNER ──────────────────────────
                  _buildHero(initials, name, rollNo, dept, email, points),

                  const SizedBox(height: 16),

                  // ── STATS ROW ────────────────────────────
                  _buildStatsRow(),

                  const SizedBox(height: 16),

                  // ── PROFILE INFO CARD ────────────────────
                  _buildProfileCard(
                      rollNo, dept, email, faName, faEmail),

                  const SizedBox(height: 16),

                  // ── SUBMISSIONS HEADER ───────────────────
                  Row(
                    children: [
                      const Text(
                        "Submissions",
                        style: TextStyle(
                          color: _navy,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const Spacer(),
                      _pill("$_totalSubs total", _muted,
                          const Color(0xFFE8EEF5)),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // ── SUBMISSIONS LIST ─────────────────────
                  if (submissions.isEmpty)
                    _buildEmptySubs()
                  else
                    ...List.generate(submissions.length,
                        (i) => _buildSubmissionCard(submissions[i], i)),
                ],
              ),
            ),
    );
  }

  // ── HERO BANNER ─────────────────────────────────────────
  Widget _buildHero(String initials, String name, String rollNo,
      String dept, String email, int points) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF03305A), Color(0xFF1A5C94)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: _navy.withOpacity(0.22),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 62, height: 62,
            decoration: BoxDecoration(
              color: _white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _white.withOpacity(0.28), width: 1.5),
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  color: _white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: _white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    height: 1.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _heroBadge(rollNo),
                    const SizedBox(width: 6),
                    Flexible(child: _heroBadge(dept)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: TextStyle(
                    color: _white.withOpacity(0.55),
                    fontSize: 11.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Points pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: _white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _white.withOpacity(0.22)),
            ),
            child: Column(
              children: [
                Text(
                  "$points",
                  style: const TextStyle(
                    color: Color(0xFF6EEAC8),
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    height: 1,
                  ),
                ),
                Text(
                  "pts",
                  style: TextStyle(
                    color: _white.withOpacity(0.6),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroBadge(String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: _white.withOpacity(0.14),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: _white.withOpacity(0.2)),
        ),
        child: Text(
          label,
          style: TextStyle(
              color: _white.withOpacity(0.85),
              fontSize: 11,
              fontWeight: FontWeight.w600),
          overflow: TextOverflow.ellipsis,
        ),
      );

  // ── STATS ROW ───────────────────────────────────────────
  Widget _buildStatsRow() {
    return Row(
      children: [
        _statCard("$_approvedSubs", "Approved", _green,
            Icons.check_circle_rounded),
        const SizedBox(width: 8),
        _statCard("$_pendingSubs", "Pending", _amber,
            Icons.hourglass_top_rounded),
        const SizedBox(width: 8),
        _statCard("$_rejectedSubs", "Rejected", _red,
            Icons.cancel_rounded),
      ],
    );
  }

  Widget _statCard(String val, String label, Color color, IconData icon) =>
      Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: _white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _border),
            boxShadow: [
              BoxShadow(
                color: _navy.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 6),
              Text(
                val,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  height: 1,
                ),
              ),
              const SizedBox(height: 3),
              Text(label,
                  style: TextStyle(
                      color: _muted,
                      fontSize: 10,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      );

  // ── PROFILE INFO CARD ───────────────────────────────────
  Widget _buildProfileCard(String rollNo, String dept, String email,
      String faName, String faEmail) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: _navy.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Profile Info",
            style: TextStyle(
              color: _navy,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 14),
          Divider(color: _border, height: 1),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _infoRow(Icons.badge_rounded, "Roll No", rollNo)),
              const SizedBox(width: 12),
              Expanded(child: _infoRow(Icons.apartment_rounded, "Dept", dept)),
            ],
          ),
          const SizedBox(height: 14),
          _infoRow(Icons.email_outlined, "Email", email),
          if (faName.isNotEmpty && faName != "—") ...[
            const SizedBox(height: 14),
            Divider(color: _border, height: 1),
            const SizedBox(height: 14),
            Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: _navy.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.school_rounded,
                      color: _navy, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        faName,
                        style: const TextStyle(
                          color: _navy,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Faculty Advisor",
                        style: TextStyle(
                            color: _green,
                            fontSize: 11,
                            fontWeight: FontWeight.w600),
                      ),
                      if (faEmail.isNotEmpty)
                        Text(faEmail,
                            style: const TextStyle(
                                color: _muted, fontSize: 11),
                            overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: _muted),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style:
                        const TextStyle(color: _hint, fontSize: 11)),
                const SizedBox(height: 2),
                Text(
                  value.isNotEmpty ? value : "—",
                  style: const TextStyle(
                    color: _navy,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      );

  // ── SUBMISSION CARD ─────────────────────────────────────
  Widget _buildSubmissionCard(Map sub, int index) {
    final status     = sub["status"] ?? "PENDING";
    final accentC    = _statusColor(status);
    final points     = sub["points"] ?? 0;
    final isApproved = status == "APPROVED";

    final avatarBgs = [
      const Color(0xFFDCEAF8),
      const Color(0xFFD1F0E5),
      const Color(0xFFFDE8D0),
      const Color(0xFFEDE1F8),
      const Color(0xFFFFE0E0),
    ];
    final avatarFgs = [
      _navy,
      _green,
      const Color(0xFFF59E0B),
      const Color(0xFF7C3AED),
      const Color(0xFFE24B4A),
    ];
    final ci = index % avatarBgs.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: _navy.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Title row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: avatarBgs[ci],
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(Icons.description_rounded,
                    color: avatarFgs[ci], size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sub["title"] ?? "—",
                      style: const TextStyle(
                        color: _navy,
                        fontWeight: FontWeight.w800,
                        fontSize: 13.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      sub["category"] ?? "—",
                      style: const TextStyle(
                          color: _muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Status pill
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: accentC.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: accentC.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_statusIcon(status), color: accentC, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      _statusLabel(status),
                      style: TextStyle(
                        color: accentC,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),
          Divider(color: _border, height: 1),
          const SizedBox(height: 10),

          // Points + View Doc
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isApproved
                      ? _green.withOpacity(0.08)
                      : const Color(0xFFE8EEF5),
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(
                    color: isApproved
                        ? _green.withOpacity(0.28)
                        : _border,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.stars_rounded,
                        size: 14,
                        color: isApproved ? _green : _muted),
                    const SizedBox(width: 5),
                    Text(
                      "$points pts",
                      style: TextStyle(
                        color: isApproved ? _green : _muted,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _openDoc(sub["proofFile"]),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 11, vertical: 7),
                  decoration: BoxDecoration(
                    color: _navy.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(color: _navy.withOpacity(0.15)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.open_in_new_rounded,
                          size: 13, color: _navy),
                      SizedBox(width: 5),
                      Text(
                        "View Proof",
                        style: TextStyle(
                          color: _navy,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Remarks
          if (sub["remarks"] != null &&
              (sub["remarks"] as String).isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: _bg,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: _border),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.comment_rounded,
                      size: 13, color: _muted),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      sub["remarks"],
                      style: const TextStyle(
                          color: _muted, fontSize: 12, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── HELPERS ─────────────────────────────────────────────
  Widget _pill(String label, Color textColor, Color bgColor) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _border),
        ),
        child: Text(
          label,
          style: TextStyle(
              color: textColor, fontSize: 12, fontWeight: FontWeight.w600),
        ),
      );

  Widget _buildLoader() => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 44, height: 44,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: _navy,
                backgroundColor: _border,
              ),
            ),
            SizedBox(height: 14),
            Text("Loading student details…",
                style: TextStyle(color: _muted, fontSize: 13)),
          ],
        ),
      );

  Widget _buildEmptySubs() => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  color: _white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: _border),
                ),
                child: const Icon(Icons.history_toggle_off_rounded,
                    color: _hint, size: 30),
              ),
              const SizedBox(height: 14),
              const Text("No submissions yet",
                  style: TextStyle(
                      color: _navy,
                      fontSize: 14,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              const Text("This student has not submitted any activities.",
                  style: TextStyle(color: _muted, fontSize: 12),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      );
}
