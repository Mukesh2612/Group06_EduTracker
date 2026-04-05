import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api.dart';

// ═══════════════════════════════════════════════════════
// NOTIFICATION PAGE
// ═══════════════════════════════════════════════════════
class NotificationPage extends StatefulWidget {
  final int studentId;

  const NotificationPage({super.key, required this.studentId});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List notifications = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchNotifications();
    // ── Mark all as read when user opens this page ──────
    markAllAsRead();
  }

  Future<void> fetchNotifications() async {
    final res = await http.get(
      Uri.parse(Api.notifications(widget.studentId)),
    );

    if (res.statusCode == 200) {
      setState(() {
        notifications = json.decode(res.body);
        loading = false;
      });
    }
  }

  // ── Tells backend to mark all as read ───────────────
  Future<void> markAllAsRead() async {
    await http.post(
      Uri.parse("$BASE_URL/notifications/mark-read/${widget.studentId}"),
    );
  }

  IconData getIcon(String status) {
    if (status == "APPROVED") return Icons.check_circle;
    if (status == "REJECTED") return Icons.cancel;
    return Icons.notifications;
  }

  Color getColor(String status) {
    if (status == "APPROVED") return Colors.green;
    if (status == "REJECTED") return Colors.red;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: const Text("Notifications"),
        elevation: 0,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.notifications_off,
                size: 60, color: Colors.grey),
            SizedBox(height: 10),
            Text("No notifications yet",
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final n = notifications[index];
          final status = n['status'] ?? "";
          // ── Unread = show slightly highlighted bg ──
          final bool isUnread = !(n['read'] ?? false);

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              // unread = light blue tint, read = white
              color: isUnread
                  ? const Color(0xFFEEF4FF)
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  blurRadius: 8,
                  color: Colors.black.withOpacity(0.05),
                )
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: getColor(status).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    getIcon(status),
                    color: getColor(status),
                  ),
                ),
                const SizedBox(width: 12),

                /// TEXT
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              n['title'] ?? "",
                              style: TextStyle(
                                fontWeight: isUnread
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          // ── Red dot for unread ──
                          if (isUnread)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        n['message'] ?? "",
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
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

// ═══════════════════════════════════════════════════════
// NOTIFICATION BELL ICON WITH RED DOT BADGE
// Use this widget wherever you show the bell icon
// (student_dashboard.dart, app bar, bottom nav, etc.)
// ═══════════════════════════════════════════════════════
class NotificationBell extends StatefulWidget {
  final int studentId;
  final VoidCallback onTap;

  const NotificationBell({
    super.key,
    required this.studentId,
    required this.onTap,
  });

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  int unreadCount = 0;

  @override
  void initState() {
    super.initState();
    fetchUnreadCount();
  }

  // ── Fetch unread count from backend ─────────────────
  Future<void> fetchUnreadCount() async {
    try {
      final res = await http.get(
        Uri.parse(
            "$BASE_URL/notifications/unread-count/${widget.studentId}"),
      );
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        setState(() {
          unreadCount = data['count'] ?? 0;
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // ── Reset dot immediately on tap ─────────────
        setState(() => unreadCount = 0);
        widget.onTap();
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(Icons.notifications_outlined, size: 28),

          // ── Red dot — only shows if unread > 0 ──────
          if (unreadCount > 0)
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}