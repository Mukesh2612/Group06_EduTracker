import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api.dart';
import '../Fa/review_application_page.dart';

class FANotificationPage extends StatefulWidget {
  final int faId;

  const FANotificationPage({super.key, required this.faId});

  @override
  State<FANotificationPage> createState() => _FANotificationPageState();
}

class _FANotificationPageState extends State<FANotificationPage> {

  static const bg    = Color(0xFFE8E9EB);
  static const light = Color(0xFFCCCDC6);
  static const dark  = Color(0xFF746D69);
  static const black = Color(0xFF262626);

  List notifications = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    try {
      final res = await http.get(
        Uri.parse(Api.faNotifications(widget.faId)),
      );

      if (res.statusCode == 200) {
        setState(() {
          notifications = json.decode(res.body);
          loading = false;
        });

        // Mark all as read after fetching — clears red dot on bell
        await http.post(
          Uri.parse("$BASE_URL/notifications/fa-mark-read/${widget.faId}"),
        );
      } else {
        setState(() => loading = false);
      }
    } catch (e) {
      print("FA NOTIFICATION ERROR: $e");
      setState(() => loading = false);
    }
  }

  IconData getIcon(String status) {
    if (status == "NEW")      return Icons.assignment;
    if (status == "APPROVED") return Icons.check_circle;
    if (status == "REJECTED") return Icons.cancel;
    return Icons.notifications;
  }

  Color getColor(String status) {
    if (status == "NEW")      return Colors.blue;
    if (status == "APPROVED") return Colors.green;
    if (status == "REJECTED") return Colors.red;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        title: const Text(
          "Notifications",
          style: TextStyle(
            color: black,
            fontWeight: FontWeight.w900,
          ),
        ),
        iconTheme: const IconThemeData(color: black),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
          ? const Center(
        child: Text(
          "No notifications yet",
          style: TextStyle(color: dark),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final n        = notifications[index];
          final status   = n['status'] ?? "";

          // FIX: read isRead from backend response
          final bool isUnread = !(n['read'] ?? false);

          return GestureDetector(
            onTap: () {
              if (status == "NEW") {
                final message = n['message'] ?? "";
                final match = RegExp(r'Student (.+?) submitted')
                    .firstMatch(message);
                final studentName = match?.group(1) ?? "";

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ReviewApplicationPage(
                      faId: widget.faId,
                      highlightStudent: studentName,
                    ),
                  ),
                );
              }
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                // FIX: blue tint for unread, white for read
                color: isUnread
                    ? const Color(0xFFEEF4FF)
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  // FIX: blue border for unread
                  color: isUnread
                      ? const Color(0xFFBDD4FF)
                      : light,
                ),
              ),
              child: Row(
                children: [

                  // Icon box
                  Container(
                    height: 44,
                    width: 44,
                    decoration: BoxDecoration(
                      color: getColor(status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: light),
                    ),
                    child: Icon(
                      getIcon(status),
                      color: getColor(status),
                      size: 22,
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Title + message
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
                                  // FIX: bold if unread
                                  fontWeight: isUnread
                                      ? FontWeight.w900
                                      : FontWeight.w600,
                                  color: black,
                                  fontSize: 14,
                                ),
                              ),
                            ),

                            // FIX: red dot for unread
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
                            color: dark,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Arrow for NEW notifications
                  if (status == "NEW")
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: dark,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}