import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'fa_notification_page.dart';
import '../config/api.dart';
import '../auth/login_page.dart';
import 'review_application_page.dart';

// ══════════════════════════════════════════════════════════
// DESIGN TOKENS
// ══════════════════════════════════════════════════════════
class _C {
  static const bg        = Color(0xFFF5F7FA);
  static const navy      = Color(0xFF03305A);
  static const white     = Colors.white;
  static const border    = Color(0xFFD8E3ED);
  static const muted     = Color(0xFF6B7C93);
  static const hint      = Color(0xFFAAB8C5);
  static const green     = Color(0xFF1D9E75);
  static const red       = Color(0xFFE24B4A);
  static const navyLight = Color(0xFFE8EEF5);
  static const amber     = Color(0xFFF59E0B);
}

// ══════════════════════════════════════════════════════════
// FA NOTIFICATION BELL
// ══════════════════════════════════════════════════════════
class FANotificationBell extends StatefulWidget {
  final int faId;
  const FANotificationBell({super.key, required this.faId});

  @override
  State<FANotificationBell> createState() => _FANotificationBellState();
}

class _FANotificationBellState extends State<FANotificationBell>
    with SingleTickerProviderStateMixin {
  int unreadCount = 0;
  late AnimationController _pulse;
  late Animation<double>   _scale;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 1.0, end: 1.4).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );
    fetchUnreadCount();
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  Future<void> fetchUnreadCount() async {
    try {
      final res = await http.get(Uri.parse(
          "$BASE_URL/notifications/fa-unread-count/${widget.faId}"));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (mounted) setState(() => unreadCount = data['count'] ?? 0);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        setState(() => unreadCount = 0);
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FANotificationPage(faId: widget.faId),
          ),
        );
        fetchUnreadCount();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _C.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _C.border),
                boxShadow: [
                  BoxShadow(
                    color: _C.navy.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.notifications_outlined,
                  color: _C.navy, size: 20),
            ),
            if (unreadCount > 0)
              Positioned(
                right: -3,
                top: -3,
                child: AnimatedBuilder(
                  animation: _scale,
                  builder: (_, child) =>
                      Transform.scale(scale: _scale.value, child: child),
                  child: Container(
                    width: 13,
                    height: 13,
                    decoration: BoxDecoration(
                      color: _C.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: _C.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: _C.red.withOpacity(0.45),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
// FA DASHBOARD
// ══════════════════════════════════════════════════════════
class FADashboard extends StatefulWidget {
  final Map user;
  const FADashboard({super.key, required this.user});

  @override
  State<FADashboard> createState() => _FADashboardState();
}

class _FADashboardState extends State<FADashboard>
    with SingleTickerProviderStateMixin {

  int? targetPoints;
  final TextEditingController goalController = TextEditingController();

  List students = [];
  bool loading  = true;

  final GlobalKey<_FANotificationBellState> _bellKey = GlobalKey();
  late AnimationController _fadeCtrl;
  late Animation<double>   _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim =
        CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    fetchStudents();
    FirebaseMessaging.onMessage.listen((_) {
      if (mounted) _bellKey.currentState?.fetchUnreadCount();
    });
  }

  @override
  void dispose() {
    goalController.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> fetchStudents() async {
    setState(() => loading = true);
    _fadeCtrl.reset();
    try {
      final faId = widget.user["id"];
      final res =
          await http.get(Uri.parse("$BASE_URL/admin/students/$faId"));
      if (res.statusCode == 200) {
        setState(() {
          students = jsonDecode(res.body);
          loading  = false;
        });
        _fadeCtrl.forward();
      } else {
        setState(() => loading = false);
      }
    } catch (e) {
      debugPrint("ERROR: $e");
      setState(() => loading = false);
    }
  }

  void logout() => Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (_) => false,
      );

  void msg(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text,
            style: const TextStyle(
                color: _C.white, fontWeight: FontWeight.w600)),
        backgroundColor: _C.navy,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ── Set Goal Dialog ────────────────────────────────────
  void showSetGoalDialog() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: _C.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                    color: _C.navy,
                    borderRadius: BorderRadius.circular(14)),
                child: const Icon(Icons.flag_rounded,
                    color: Colors.white, size: 24),
              ),
              const SizedBox(height: 16),
              const Text("Set Target Points",
                  style: TextStyle(
                      color: _C.navy,
                      fontSize: 18,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              const Text(
                "Students meeting this goal will be highlighted in green.",
                style: TextStyle(color: _C.muted, fontSize: 13),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: goalController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: _C.navy),
                cursorColor: _C.navy,
                decoration: InputDecoration(
                  hintText: "e.g. 100",
                  hintStyle: const TextStyle(color: _C.hint),
                  filled: true,
                  fillColor: _C.bg,
                  prefixIcon: const Icon(Icons.stars_rounded,
                      color: _C.navy, size: 20),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: _C.border)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: _C.border)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: _C.navy, width: 1.5)),
                ),
              ),
              const SizedBox(height: 20),
              Row(children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      goalController.clear();
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: _C.muted,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: _C.border),
                      ),
                    ),
                    child: const Text("Cancel",
                        style:
                            TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _C.navy,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding:
                          const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      final val =
                          int.tryParse(goalController.text.trim());
                      if (val == null || val <= 0) {
                        msg("Enter valid points");
                        return;
                      }
                      setState(() => targetPoints = val);
                      goalController.clear();
                      Navigator.pop(context);
                      msg("Target set to $val points ✓");
                    },
                    child: const Text("Set Goal",
                        style:
                            TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  // ── App-bar icon button ────────────────────────────────
  Widget _appBarBtn(IconData icon, VoidCallback onTap,
          {EdgeInsets margin =
              const EdgeInsets.only(right: 4)}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40, height: 40,
          margin: margin,
          decoration: BoxDecoration(
            color: _C.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _C.border),
            boxShadow: [
              BoxShadow(
                color: _C.navy.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, color: _C.navy, size: 20),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final name       = widget.user["name"]  ?? "Faculty Advisor";
    final department = widget.user["dept"]  ?? "—";
    final email      = widget.user["email"] ?? "—";
    final faId       = widget.user["id"] as int;

    final total     = students.length;
    final aboveGoal = targetPoints == null
        ? 0
        : students
            .where((s) => (s["points"] ?? 0) >= targetPoints!)
            .length;

    return Scaffold(
      backgroundColor: _C.bg,

      // ── PINNED BOTTOM BUTTON ─────────────────────────
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _C.navy,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
              ),
              icon: const Icon(Icons.pending_actions_rounded, size: 20),
              label: const Text(
                "View Pending Requests",
                style: TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 15),
              ),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        ReviewApplicationPage(faId: faId),
                  ),
                );
                fetchStudents();
              },
            ),
          ),
        ),
      ),

      // ── APP BAR ────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: _C.bg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Row(
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                  color: _C.navy,
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.school_rounded,
                  color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            const Text(
              "FA Dashboard",
              style: TextStyle(
                color: _C.navy,
                fontWeight: FontWeight.w800,
                fontSize: 18,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        actions: [
          _appBarBtn(Icons.refresh_rounded, () {
            fetchStudents();
            _bellKey.currentState?.fetchUnreadCount();
          }),
          FANotificationBell(key: _bellKey, faId: faId),
          _appBarBtn(
            Icons.logout_rounded,
            logout,
            margin: const EdgeInsets.only(left: 4, right: 12),
          ),
        ],
      ),

      // ── BODY — full CustomScrollView ──────────────────
      body: loading
          ? _buildLoader()
          : CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [

                // ── HERO CARD ─────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: _buildHeroCard(
                        name, department, email,
                        total, aboveGoal),
                  ),
                ),

                // ── SECTION HEADER ────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                    child: Row(
                      children: [
                        const Text(
                          "Assigned Students",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: _C.navy,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _C.navyLight,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: _C.border),
                          ),
                          child: Text(
                            "$total enrolled",
                            style: const TextStyle(
                              color: _C.muted,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── STUDENT LIST ──────────────────────
                students.isEmpty
                    ? SliverToBoxAdapter(child: _buildEmpty())
                    : SliverPadding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 16),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (ctx, i) => _StudentTile(
                              student: students[i],
                              targetPoints: targetPoints,
                              index: i,
                            ),
                            childCount: students.length,
                          ),
                        ),
                      ),

                // Footer
                SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 8),
                      child: Text(
                        "EduTracker",
                        style: TextStyle(
                          color: _C.hint,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),

              ],
            ),
    );
  }

  // ── HERO CARD ─────────────────────────────────────────
  Widget _buildHeroCard(String name, String dept, String email,
      int total, int aboveGoal) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF03305A), Color(0xFF1A5C94)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: _C.navy.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [

          // Avatar + info
          Row(
            children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.25), width: 1.5),
                ),
                child: Center(
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : "F",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _heroChip("Faculty Advisor"),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            dept,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          Divider(color: Colors.white.withOpacity(0.18), height: 1),
          const SizedBox(height: 14),

          // Stat row
          Row(
            children: [
              _statPill("Students", "$total",
                  Icons.people_alt_rounded, Colors.white),
              const SizedBox(width: 10),
              _statPill(
                  "Above Goal",
                  targetPoints == null ? "—" : "$aboveGoal",
                  Icons.workspace_premium_rounded,
                  const Color(0xFF6EEAC8)),
              const SizedBox(width: 10),
              _statPill(
                  "Target",
                  targetPoints == null ? "—" : "${targetPoints}pt",
                  Icons.flag_rounded,
                  const Color(0xFFFBD07A)),
            ],
          ),

          const SizedBox(height: 12),

          // Goal button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: _C.navy,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.flag_rounded, size: 17),
              label: Text(
                targetPoints == null
                    ? "Set Progress Goal"
                    : "Update Goal  (${targetPoints}pts)",
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 14),
              ),
              onPressed: showSetGoalDialog,
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroChip(String label) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Text(label,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700)),
      );

  Widget _statPill(
          String label, String value, IconData icon, Color accent) =>
      Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: Colors.white.withOpacity(0.18)),
          ),
          child: Column(
            children: [
              Icon(icon, color: accent, size: 18),
              const SizedBox(height: 4),
              Text(value,
                  style: TextStyle(
                      color: accent,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      height: 1)),
              const SizedBox(height: 2),
              Text(label,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 10)),
            ],
          ),
        ),
      );

  Widget _buildLoader() => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 44, height: 44,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(_C.navy),
                backgroundColor: _C.border,
              ),
            ),
            const SizedBox(height: 14),
            const Text("Loading students…",
                style: TextStyle(color: _C.muted, fontSize: 13)),
          ],
        ),
      );

  Widget _buildEmpty() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                  color: _C.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: _C.border),
                ),
                child: const Icon(Icons.people_outline_rounded,
                    color: _C.hint, size: 36),
              ),
              const SizedBox(height: 16),
              const Text("No students assigned yet",
                  style: TextStyle(
                      color: _C.navy,
                      fontSize: 15,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              const Text("Students will appear once assigned.",
                  style: TextStyle(color: _C.muted, fontSize: 13)),
            ],
          ),
        ),
      );
}

// ══════════════════════════════════════════════════════════
// STUDENT TILE
// ══════════════════════════════════════════════════════════
class _StudentTile extends StatefulWidget {
  final Map  student;
  final int? targetPoints;
  final int  index;

  const _StudentTile({
    required this.student,
    required this.targetPoints,
    required this.index,
  });

  @override
  State<_StudentTile> createState() => _StudentTileState();
}

class _StudentTileState extends State<_StudentTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _slide;
  late Animation<double>   _fade;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 320 + widget.index * 40),
    );
    _slide = Tween<double>(begin: 28, end: 0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _fade = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    Future.delayed(Duration(milliseconds: widget.index * 55), () {
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
    final s      = widget.student;
    final points = s["points"] ?? 0;
    final tp     = widget.targetPoints;

    final meetsGoal = tp != null && points >= tp;
    final misses    = tp != null && points < tp;
    final ptColor   = tp == null ? _C.navy : (meetsGoal ? _C.green : _C.red);

    final avatarBgs = [
      const Color(0xFFDCEAF8),
      const Color(0xFFD1F0E5),
      const Color(0xFFFDE8D0),
      const Color(0xFFEDE1F8),
      const Color(0xFFFFE0E0),
    ];
    final avatarFgs = [
      const Color(0xFF03305A),
      const Color(0xFF1D9E75),
      const Color(0xFFF59E0B),
      const Color(0xFF7C3AED),
      const Color(0xFFE24B4A),
    ];
    final ci = widget.index % avatarBgs.length;

    final initials = (s["name"] as String? ?? "?")
        .trim()
        .split(" ")
        .take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : "")
        .join();

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) => Opacity(
        opacity: _fade.value,
        child: Transform.translate(
            offset: Offset(0, _slide.value), child: child),
      ),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 120),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _C.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: meetsGoal
                    ? _C.green.withOpacity(0.35)
                    : misses
                        ? _C.red.withOpacity(0.28)
                        : _C.border,
              ),
              boxShadow: [
                BoxShadow(
                  color: _C.navy.withOpacity(0.05),
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
                    color: avatarBgs[ci],
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: TextStyle(
                        color: avatarFgs[ci],
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Name + email + progress bar
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s["name"] ?? "—",
                        style: const TextStyle(
                          color: _C.navy,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        s["email"] ?? "—",
                        style: const TextStyle(
                            color: _C.muted, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (tp != null) ...[
                        const SizedBox(height: 7),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(99),
                          child: LinearProgressIndicator(
                            value: math.min(points / tp, 1.0),
                            minHeight: 4,
                            backgroundColor: _C.border,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(ptColor),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Points badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: ptColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: ptColor.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "$points",
                        style: TextStyle(
                          color: ptColor,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "pts",
                        style: TextStyle(
                          color: ptColor.withOpacity(0.65),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
