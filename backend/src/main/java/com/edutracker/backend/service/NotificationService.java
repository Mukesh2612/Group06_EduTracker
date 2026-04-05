package com.edutracker.backend.service;

import com.edutracker.backend.model.Notification;
import com.edutracker.backend.model.User;
import com.edutracker.backend.repository.NotificationRepository;
import com.edutracker.backend.repository.UserRepository;

import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.*;

@Service
public class NotificationService {

    private final NotificationRepository notificationRepository;
    private final UserRepository userRepository;

    public NotificationService(NotificationRepository notificationRepository,
                               UserRepository userRepository) {
        this.notificationRepository = notificationRepository;
        this.userRepository = userRepository;
    }

    // ── For STUDENT notifications (approve/reject) ────────
    public void createNotification(Long studentId, String title, String message, String status) {
        Notification notification = new Notification();
        notification.setStudentId(studentId);
        notification.setTitle(title);
        notification.setMessage(message);
        notification.setStatus(status);
        notification.setRead(false); // 🔴 Unread = red dot shown
        notificationRepository.save(notification);

        // Optional: push notification via FCM
        Optional<User> userOpt = userRepository.findById(studentId);
        userOpt.ifPresent(user -> {
            if (user.getFcmToken() != null) {
                sendPushNotification(user.getFcmToken(), title, message);
            }
        });
    }

    // ── For FA notifications (student submits proof) ──────
    public void createNotificationForFa(Long faId, String title, String message, String status) {
        Notification notification = new Notification();
        notification.setFaId(faId);       // stored in faId column
        notification.setTitle(title);
        notification.setMessage(message);
        notification.setStatus(status);
        notification.setRead(false);      // 🔴 Unread = red dot shown
        notificationRepository.save(notification);

        // Optional: push notification to FA via FCM
        Optional<User> userOpt = userRepository.findById(faId);
        userOpt.ifPresent(user -> {
            if (user.getFcmToken() != null) {
                sendPushNotification(user.getFcmToken(), title, message);
            }
        });
    }

    // ── Get student notifications ─────────────────────────
    public List<Notification> getStudentNotifications(Long studentId) {
        return notificationRepository.findByStudentIdOrderByCreatedAtDesc(studentId);
    }

    // ── Get FA notifications ──────────────────────────────
    public List<Notification> getFaNotifications(Long faId) {
        return notificationRepository.findByFaIdOrderByCreatedAtDesc(faId);
    }

    // ── Mark all student notifications as read ────────────
    public void markStudentNotificationsRead(Long studentId) {
        notificationRepository.markAllAsReadByStudentId(studentId);
    }

    // ── Mark all FA notifications as read ─────────────────
    public void markFaNotificationsRead(Long faId) {
        notificationRepository.markAllAsReadByFaId(faId);
    }

    // ── FCM push (optional) ───────────────────────────────
    private void sendPushNotification(String token, String title, String body) {
        try {
            String url = "https://fcm.googleapis.com/fcm/send";
            RestTemplate restTemplate = new RestTemplate();

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            headers.set("Authorization", "key=YOUR_SERVER_KEY"); // replace with your FCM key

            Map<String, Object> notification = new HashMap<>();
            notification.put("title", title);
            notification.put("body", body);

            Map<String, Object> payload = new HashMap<>();
            payload.put("to", token);
            payload.put("notification", notification);
            payload.put("priority", "high");

            HttpEntity<Map<String, Object>> request = new HttpEntity<>(payload, headers);
            restTemplate.postForObject(url, request, String.class);

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}