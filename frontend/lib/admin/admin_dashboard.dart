import 'package:flutter/material.dart';
import 'manage_users_page.dart';
import 'manage_categories_page.dart';
import '../auth/login_page.dart';

// ══════════════════════════════════════════════════════════
// ADMIN DASHBOARD
// ══════════════════════════════════════════════════════════
class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

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

  void _logout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  Widget _appBarBtn(
    IconData icon,
    VoidCallback onTap, {
    EdgeInsets margin = const EdgeInsets.only(right: 4),
  }) =>
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,

      // ── APP BAR ──────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _navy,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.admin_panel_settings_rounded,
                  color: _white, size: 18),
            ),
            const SizedBox(width: 10),
            const Text(
              "Admin Dashboard",
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
            Icons.logout_rounded,
            () => _logout(context),
            margin: const EdgeInsets.only(right: 14),
          ),
        ],
      ),

      // ── BODY ─────────────────────────────────────────────
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── HERO CARD ─────────────────────────────────
            Container(
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
                    color: _navy.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: _white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: _white.withOpacity(0.25), width: 1.5),
                    ),
                    child: const Icon(
                        Icons.admin_panel_settings_rounded,
                        color: _white,
                        size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Administrator",
                          style: TextStyle(
                            color: _white,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Manage users, roles & categories",
                          style: TextStyle(
                            color: _white.withOpacity(0.65),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── SECTION LABEL ─────────────────────────────
            const Text(
              "Quick Actions",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: _navy,
                letterSpacing: -0.2,
              ),
            ),

            const SizedBox(height: 12),

            // ── ACTION CARDS ──────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _ActionCard(
                    title: "Manage Users",
                    subtitle: "Add, edit or remove\nstudents & advisors",
                    icon: Icons.people_alt_rounded,
                    iconBg: _navy.withOpacity(0.1),
                    iconColor: _navy,
                    accentColor: _navy,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ManageUsersPage()),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionCard(
                    title: "Categories",
                    subtitle: "Configure activity\npoint categories",
                    icon: Icons.category_rounded,
                    iconBg: _amber.withOpacity(0.12),
                    iconColor: _amber,
                    accentColor: _amber,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ManageCategoriesPage()),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // ── INFO CARDS ────────────────────────────────
            const Text(
              "Overview",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: _navy,
                letterSpacing: -0.2,
              ),
            ),

            const SizedBox(height: 12),

            _InfoTile(
              icon: Icons.people_outline_rounded,
              iconBg: _navy.withOpacity(0.08),
              iconColor: _navy,
              title: "Users",
              subtitle: "Manage student & faculty advisor accounts",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const ManageUsersPage()),
              ),
            ),

            const SizedBox(height: 10),

            _InfoTile(
              icon: Icons.bookmark_outline_rounded,
              iconBg: _green.withOpacity(0.1),
              iconColor: _green,
              title: "Activity Categories",
              subtitle: "Define point values for each activity type",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const ManageCategoriesPage()),
              ),
            ),

            const SizedBox(height: 10),

            _InfoTile(
              icon: Icons.logout_rounded,
              iconBg: _red.withOpacity(0.08),
              iconColor: _red,
              title: "Logout",
              subtitle: "Sign out of the admin console",
              onTap: () => _logout(context),
            ),

            const SizedBox(height: 32),

            Center(
              child: Text(
                "EduTracker",
                style: TextStyle(
                  color: _hint,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
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
// ACTION CARD (square card in a 2×1 grid)
// ══════════════════════════════════════════════════════════
class _ActionCard extends StatefulWidget {
  final String    title;
  final String    subtitle;
  final IconData  icon;
  final Color     iconBg;
  final Color     iconColor;
  final Color     accentColor;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.accentColor,
    required this.onTap,
  });

  @override
  State<_ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<_ActionCard> {
  static const _white  = Colors.white;
  static const _border = Color(0xFFD8E3ED);
  static const _navy   = Color(0xFF03305A);

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
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: _white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _border),
            boxShadow: [
              BoxShadow(
                color: _navy.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: widget.iconBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(widget.icon,
                    color: widget.iconColor, size: 22),
              ),
              const SizedBox(height: 14),
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: _navy,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.subtitle,
                style: const TextStyle(
                    fontSize: 11, color: Color(0xFF6B7C93)),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    "Open",
                    style: TextStyle(
                      color: widget.accentColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Icon(Icons.arrow_forward_rounded,
                      size: 13, color: widget.accentColor),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
// INFO TILE (list-style action row)
// ══════════════════════════════════════════════════════════
class _InfoTile extends StatefulWidget {
  final IconData icon;
  final Color    iconBg;
  final Color    iconColor;
  final String   title;
  final String   subtitle;
  final VoidCallback onTap;

  const _InfoTile({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  State<_InfoTile> createState() => _InfoTileState();
}

class _InfoTileState extends State<_InfoTile> {
  static const _white  = Colors.white;
  static const _border = Color(0xFFD8E3ED);
  static const _navy   = Color(0xFF03305A);
  static const _muted  = Color(0xFF6B7C93);
  static const _hint   = Color(0xFFAAB8C5);
  static const _bg     = Color(0xFFF5F7FA);

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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 110),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _pressed ? _bg : _white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _border),
          boxShadow: [
            BoxShadow(
              color: _navy.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: widget.iconBg,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(widget.icon,
                  color: widget.iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _navy,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.subtitle,
                    style: const TextStyle(
                        fontSize: 12, color: _muted),
                  ),
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
    );
  }
}
