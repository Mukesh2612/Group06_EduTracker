package com.edutracker.backend.controller;

import com.edutracker.backend.model.Notification;
import com.edutracker.backend.repository.NotificationRepository;
import com.edutracker.backend.service.NotificationService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/notifications")
@CrossOrigin("*")
public class NotificationController {

    private final NotificationService notificationService;
    private final NotificationRepository notificationRepository;

    public NotificationController(NotificationService notificationService,
                                  NotificationRepository notificationRepository) {
        this.notificationService    = notificationService;
        this.notificationRepository = notificationRepository;
    }

    // ── Student: get all notifications ────────────────────
    @GetMapping("/{studentId}")
    public List<Notification> getNotifications(@PathVariable Long studentId) {
        return notificationService.getStudentNotifications(studentId);
    }

    // ── Student: unread count (red dot) ───────────────────
    @GetMapping("/unread-count/{studentId}")
    public ResponseEntity<?> getUnreadCount(@PathVariable Long studentId) {
        long count = notificationRepository.countByStudentIdAndIsReadFalse(studentId);
        return ResponseEntity.ok(Map.of("count", count));
    }

    // ── Student: mark all as read (clears red dot) ────────
    @PostMapping("/mark-read/{studentId}")
    public ResponseEntity<?> markAllRead(@PathVariable Long studentId) {
        notificationService.markStudentNotificationsRead(studentId);
        return ResponseEntity.ok("Marked as read");
    }

    // ── FA: get all notifications ─────────────────────────
    @GetMapping("/fa/{faId}")
    public List<Notification> getFaNotifications(@PathVariable Long faId) {
        return notificationService.getFaNotifications(faId);
    }

    // ── FA: unread count (red dot) ────────────────────────
    @GetMapping("/fa-unread-count/{faId}")
    public ResponseEntity<?> getFaUnreadCount(@PathVariable Long faId) {
        long count = notificationRepository.countByFaIdAndIsReadFalse(faId);
        return ResponseEntity.ok(Map.of("count", count));
    }

    // ── FA: mark all as read (clears red dot) ─────────────
    @PostMapping("/fa-mark-read/{faId}")
    public ResponseEntity<?> markFaAllRead(@PathVariable Long faId) {
        notificationService.markFaNotificationsRead(faId);
        return ResponseEntity.ok("Marked as read");
    }
}