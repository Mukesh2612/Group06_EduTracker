import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:url_launcher/url_launcher.dart';
import 'activity_history_page.dart';
import '../auth/login_page.dart';
import '../config/api.dart';
import 'apply_activity_page.dart';
import 'generate_report_screen.dart';
import 'notification_page.dart';

// ══════════════════════════════════════════════════════════
// STUDENT DASHBOARD
// ══════════════════════════════════════════════════════════
class StudentDashboard extends StatefulWidget {
  final String email;
  final int studentId;

  const StudentDashboard({
    super.key,
    required this.email,
    required this.studentId,
  });

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard>
    with SingleTickerProviderStateMixin {

  // ── Design tokens ────────────────────────────────────────
  static const _primary   = Color(0xFF0A4B8C);
  static const _primaryDk = Color(0xFF062E59);
  static const _primaryLt = Color(0xFF1A6CBD);
  static const _bg        = Color(0xFFE8F1FB);
  static const _surface   = Colors.white;
  static const _border    = Color(0xFFD0E2F3);
  static const _textDark  = Color(0xFF0A2E52);
  static const _muted     = Color(0xFF5B85AA);
  static const _hint      = Color(0xFF9AB8D0);
  static const _green     = Color(0xFF1D9E75);
  static const _red       = Color(0xFFE24B4A);
  static const _amber     = Color(0xFFF59E0B);

  // ── State ─────────────────────────────────────────────
  String name      = '';
  String rollNo    = '';
  String email     = '';
  String dept      = '';
  String faName    = '';
  String faEmail   = '';
  int    points    = 0;
  int    submitted = 0;
  int    approved  = 0;
  int    studentId = 0;
  bool   loading   = true;
  bool   hasUnread = false;

  late AnimationController _fadeCtrl;
  late Animation<double>   _fadeAnim;

  @override
  void initState() {
    super.initState();
    studentId = widget.studentId;
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim =
        CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    loadProfile();
    fetchUnreadCount();
    FirebaseMessaging.onMessage.listen((_) {
      if (mounted) fetchUnreadCount();
    });
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> fetchUnreadCount() async {
    try {
      final res = await http.get(
          Uri.parse('$BASE_URL/notifications/unread-count/$studentId'));
      if (res.statusCode == 200) {
        final d = json.decode(res.body);
        if (mounted) setState(() => hasUnread = (d['count'] ?? 0) > 0);
      }
    } catch (_) {}
  }

  void _toast(String t) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t,
              style: const TextStyle(
                  color: _surface, fontWeight: FontWeight.w600)),
          backgroundColor: _primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );

  Future<void> loadProfile() async {
    try {
      final r = await http
          .get(Uri.parse('$BASE_URL/auth/student/profile/${widget.email}'));
      if (r.statusCode == 200) {
        final d = jsonDecode(r.body);
        setState(() {
          studentId = d['id']        ?? 0;
          name      = d['name']      ?? '';
          rollNo    = d['rollNo']    ?? '';
          email     = d['email']     ?? '';
          dept      = d['dept']      ?? '';
          faName    = d['faName']    ?? '';
          faEmail   = d['faEmail']   ?? '';
          points    = d['points']    ?? 0;
          submitted = d['submitted'] ?? 0;
          approved  = d['approved']  ?? 0;
          loading   = false;
        });
        _fadeCtrl.forward();
        fetchUnreadCount();
      } else {
        _toast('Server error');
      }
    } catch (_) {
      _toast('Backend connection failed');
    }
  }

  Future<void> sendEmail() async {
    final uri = Uri(
      scheme: 'mailto',
      path: faEmail,
      query: Uri.encodeFull(
          'subject=Query from Student&body=Hello $faName,\n\n'
          'Name: $name\nRoll No: $rollNo\nDept: $dept\nEmail: $email\n'),
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _toast('Could not open email app');
    }
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: _surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: _red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.logout_rounded,
                    color: _red, size: 24),
              ),
              const SizedBox(height: 14),
              const Text('Logout',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: _textDark)),
              const SizedBox(height: 6),
              const Text('Are you sure you want to logout?',
                  style: TextStyle(fontSize: 13, color: _muted)),
              const SizedBox(height: 22),
              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _muted,
                      side: const BorderSide(color: _border),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding:
                          const EdgeInsets.symmetric(vertical: 13),
                    ),
                    child: const Text('Cancel',
                        style:
                            TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _red,
                      foregroundColor: _surface,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding:
                          const EdgeInsets.symmetric(vertical: 13),
                    ),
                    child: const Text('Logout',
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
    if (confirmed == true && mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => LoginPage()),
        (_) => false,
      );
    }
  }

  String _initials(String n) {
    final p = n.trim().split(' ');
    if (p.length >= 2) return '${p[0][0]}${p[1][0]}'.toUpperCase();
    return n.isNotEmpty ? n[0].toUpperCase() : '?';
  }

  Widget _appBtn(Widget child, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _surface.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border:
                Border.all(color: _surface.withOpacity(0.22)),
          ),
          child: Center(child: child),
        ),
      );

  // ── BUILD ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        backgroundColor: _bg,
        body: Center(
            child: CircularProgressIndicator(color: _primary)),
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _bg,
        body: FadeTransition(
          opacity: _fadeAnim,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── HERO CARD (header + stats fused) ──
                _buildHeroCard(),

                const SizedBox(height: 20),

                // ── PROFILE + ADVISOR ─────────────────
                _sectionLabel('Profile & Advisor'),
                _buildProfileCard(),

                const SizedBox(height: 20),

                // ── ACTIONS ───────────────────────────
                _sectionLabel('Quick Actions'),
                _buildActions(),

                const SizedBox(height: 32),
                Center(
                  child: Text(
                    'EduTracker',
                    style: TextStyle(
                      color: _hint,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  // HERO CARD  — gradient bg, avatar, name, 3 stat pills
  // ══════════════════════════════════════════════════════
  Widget _buildHeroCard() {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, top + 20, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_primaryDk, _primary, _primaryLt],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Top bar: welcome + icon buttons
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  'Welcome back 👋',
                  style: TextStyle(
                    color: _surface.withOpacity(0.65),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              _appBtn(
                Stack(clipBehavior: Clip.none, children: [
                  const Icon(Icons.notifications_outlined,
                      size: 20, color: _surface),
                  if (hasUnread)
                    Positioned(
                      right: -3,
                      top: -3,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _red,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: _primary, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: _red.withOpacity(0.45),
                              blurRadius: 5,
                            ),
                          ],
                        ),
                      ),
                    ),
                ]),
                () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          NotificationPage(studentId: studentId),
                    ),
                  );
                  fetchUnreadCount();
                },
              ),
              const SizedBox(width: 8),
              _appBtn(
                const Icon(Icons.logout_rounded,
                    size: 20, color: _surface),
                _confirmLogout,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Avatar + name + roll/dept
          Row(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: _surface.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                      color: _surface.withOpacity(0.28), width: 1.5),
                ),
                child: Center(
                  child: Text(
                    _initials(name),
                    style: const TextStyle(
                      color: _surface,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
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
                        color: _surface,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        height: 1.2,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _headerChip(rollNo),
                        const SizedBox(width: 6),
                        Flexible(child: _headerChip(dept)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Divider
          Divider(color: _surface.withOpacity(0.15), height: 1),

          const SizedBox(height: 18),

          // Stat pills row
          Row(
            children: [
              _statPill(
                '$points',
                'Points',
                Icons.stars_rounded,
                const Color(0xFF6EEAC8),
              ),
              const SizedBox(width: 10),
              _statPill(
                '$submitted',
                'Submitted',
                Icons.upload_rounded,
                const Color(0xFFFBD07A),
              ),
              const SizedBox(width: 10),
              _statPill(
                '$approved',
                'Approved',
                Icons.check_circle_rounded,
                const Color(0xFF6EEAC8),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerChip(String label) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: _surface.withOpacity(0.14),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _surface.withOpacity(0.2)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: _surface.withOpacity(0.85),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      );

  Widget _statPill(
          String value, String label, IconData icon, Color accent) =>
      Expanded(
        child: Container(
          padding:
              const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: _surface.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
            border:
                Border.all(color: _surface.withOpacity(0.18)),
          ),
          child: Column(
            children: [
              Icon(icon, color: accent, size: 18),
              const SizedBox(height: 5),
              Text(
                value,
                style: TextStyle(
                  color: accent,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  height: 1,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  color: _surface.withOpacity(0.6),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );

  // ── Section label ──────────────────────────────────────
  Widget _sectionLabel(String t) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
        child: Text(
          t,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: _textDark,
            letterSpacing: -0.2,
          ),
        ),
      );

  // ══════════════════════════════════════════════════════
  // PROFILE CARD
  // ══════════════════════════════════════════════════════
  Widget _buildProfileCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: _border),
          boxShadow: [
            BoxShadow(
              color: _primary.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: _infoField('Full Name', name)),
                const SizedBox(width: 16),
                Expanded(child: _infoField('Roll No.', rollNo)),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: _infoField('Department', dept)),
                const SizedBox(width: 16),
                Expanded(
                    child: _infoField('Email', email, small: true)),
              ],
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1, color: _border),
            ),

            // Faculty advisor
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(
                        color: _primary.withOpacity(0.2)),
                  ),
                  child: Center(
                    child: Text(
                      _initials(faName),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: _primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(faName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _textDark,
                          )),
                      const SizedBox(height: 3),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: _primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Faculty Advisor',
                          style: TextStyle(
                            color: _primary,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(faEmail,
                          style: const TextStyle(
                              fontSize: 11, color: _muted),
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: sendEmail,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: _primary.withOpacity(0.2)),
                    ),
                    child: const Icon(Icons.mail_outline_rounded,
                        size: 18, color: _primary),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoField(String label, String value,
          {bool small = false}) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  const TextStyle(fontSize: 11, color: _muted)),
          const SizedBox(height: 3),
          Text(
            value.isNotEmpty ? value : '—',
            style: TextStyle(
              fontSize: small ? 12 : 13,
              fontWeight: FontWeight.w700,
              color: _textDark,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );

  // ══════════════════════════════════════════════════════
  // ACTIONS
  // ══════════════════════════════════════════════════════
  Widget _buildActions() {
    final actions = [
      _ActionItem(
        title: 'Apply Activity Points',
        subtitle: 'Upload certificate for approval',
        icon: Icons.add_task_rounded,
        iconBg: _primary.withOpacity(0.1),
        iconColor: _primary,
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  ApplyActivityScreen(studentId: studentId),
            ),
          );
          loadProfile();
        },
      ),
      _ActionItem(
        title: 'Activity History',
        subtitle: 'View all your submissions',
        icon: Icons.history_rounded,
        iconBg: _green.withOpacity(0.1),
        iconColor: _green,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                ActivityHistoryPage(studentId: studentId),
          ),
        ),
      ),
      _ActionItem(
        title: 'Generate Report',
        subtitle: 'Export your activity summary',
        icon: Icons.bar_chart_rounded,
        iconBg: _amber.withOpacity(0.12),
        iconColor: _amber,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                GenerateReportScreen(studentId: studentId),
          ),
        ),
      ),
      _ActionItem(
        title: 'Message Faculty Advisor',
        subtitle: 'Send query via email',
        icon: Icons.mail_outline_rounded,
        iconBg: _red.withOpacity(0.08),
        iconColor: _red,
        onTap: sendEmail,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: _border),
          boxShadow: [
            BoxShadow(
              color: _primary.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: List.generate(actions.length, (i) {
            return _ActionTile(
                item: actions[i], isLast: i == actions.length - 1);
          }),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
// ACTION ITEM MODEL
// ══════════════════════════════════════════════════════════
class _ActionItem {
  final String     title;
  final String     subtitle;
  final IconData   icon;
  final Color      iconBg;
  final Color      iconColor;
  final VoidCallback onTap;

  const _ActionItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.onTap,
  });
}

// ══════════════════════════════════════════════════════════
// ACTION TILE  (press highlight)
// ══════════════════════════════════════════════════════════
class _ActionTile extends StatefulWidget {
  final _ActionItem item;
  final bool        isLast;

  const _ActionTile({required this.item, required this.isLast});

  @override
  State<_ActionTile> createState() => _ActionTileState();
}

class _ActionTileState extends State<_ActionTile> {
  static const _border   = Color(0xFFD0E2F3);
  static const _textDark = Color(0xFF0A2E52);
  static const _muted    = Color(0xFF5B85AA);
  static const _hint     = Color(0xFF9AB8D0);
  static const _bg       = Color(0xFFE8F1FB);

  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final a = widget.item;
    return GestureDetector(
      onTapDown:  (_) => setState(() => _pressed = true),
      onTapUp:    (_) { setState(() => _pressed = false); a.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 110),
        decoration: BoxDecoration(
          color: _pressed ? _bg : Colors.transparent,
          borderRadius: widget.isLast
              ? const BorderRadius.vertical(bottom: Radius.circular(22))
              : BorderRadius.zero,
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: a.iconBg,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child:
                        Icon(a.icon, color: a.iconColor, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(a.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _textDark,
                            )),
                        const SizedBox(height: 2),
                        Text(a.subtitle,
                            style: const TextStyle(
                                fontSize: 12, color: _muted)),
                      ],
                    ),
                  ),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: _bg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _border),
                    ),
                    child: const Icon(Icons.chevron_right_rounded,
                        size: 16, color: _hint),
                  ),
                ],
              ),
            ),
            if (!widget.isLast)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16),
                child: Divider(height: 1, color: _border),
              ),
          ],
        ),
      ),
    );
  }
}
