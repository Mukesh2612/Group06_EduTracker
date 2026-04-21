package com.edutracker.backend.service;

import com.edutracker.backend.model.Submission;
import com.edutracker.backend.model.User;
import com.edutracker.backend.repository.SubmissionRepository;
import com.edutracker.backend.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.*;

@Service
public class SubmissionService {

    @Autowired
    private SubmissionRepository repository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private NotificationService notificationService;

    // EmailService removed — will add back when needed

    public Submission submit(Submission s) {
        s.setStatus("PENDING");
        Submission saved = repository.save(s);

        User student = userRepository.findById(s.getStudentId()).orElse(null);

        if (student != null && student.getFaId() != null) {
            User fa = userRepository.findById(student.getFaId()).orElse(null);

            if (fa != null) {
                try {
                    notificationService.createNotificationForFa(
                            fa.getId(),
                            "New Submission",
                            "Student " + student.getName() + " submitted an activity",
                            "NEW"
                    );
                } catch (Exception e) {
                    System.err.println("⚠️ FA notification failed: " + e.getMessage());
                }
            }
        }

        return saved;
    }

    public List<Submission> studentSubmissions(Long userId) {
        return repository.findByStudentId(userId);
    }

    public List<Map<String, Object>> pendingWithStudent() {
        List<Map<String, Object>> raw = repository.findPendingWithStudent();
        List<Map<String, Object>> normalized = new ArrayList<>();
        for (Map<String, Object> row : raw) {
            Map<String, Object> clean = new LinkedHashMap<>();
            row.forEach((key, value) -> clean.put(toCamel(key), value));
            normalized.add(clean);
        }
        return normalized;
    }

    private String toCamel(String key) {
        if (key == null) return key;
        if (!key.contains("_") && !key.equals(key.toLowerCase())) return key;
        Map<String, String> knownKeys = Map.of(
            "activitygroup",  "activityGroup",
            "activity_group", "activityGroup",
            "prooffile",      "proofFile",
            "proof_file",     "proofFile",
            "studentname",    "studentName",
            "student_name",   "studentName",
            "rollno",         "rollNo",
            "roll_no",        "rollNo",
            "studentid",      "studentId",
            "student_id",     "studentId"
        );
        String lower = key.toLowerCase();
        if (knownKeys.containsKey(lower)) return knownKeys.get(lower);
        StringBuilder sb = new StringBuilder();
        boolean nextUpper = false;
        for (char c : key.toCharArray()) {
            if (c == '_') nextUpper = true;
            else if (nextUpper) { sb.append(Character.toUpperCase(c)); nextUpper = false; }
            else sb.append(c);
        }
        return sb.toString();
    }

    public Submission approve(Long id) {
        Submission s = repository.findById(id).orElseThrow();
        if (s.isReviewNotificationSent()) return s;
        s.setStatus("APPROVED");
        s.setReviewNotificationSent(true);
        repository.save(s);
        User student = userRepository.findById(s.getStudentId()).orElseThrow();
        student.setPoints(student.getPoints() + s.getPoints());
        userRepository.save(student);
        notificationService.createNotification(
                s.getStudentId(),
                "Activity Approved",
                "Your activity \"" + s.getTitle() + "\" has been approved and points added!",
                "APPROVED"
        );
        return s;
    }

    public Submission reject(Long id, String remarks) {
        Submission s = repository.findById(id).orElseThrow();
        if (s.isReviewNotificationSent()) return s;
        s.setStatus("REJECTED");
        s.setRemarks(remarks);
        s.setReviewNotificationSent(true);
        repository.save(s);
        notificationService.createNotification(
                s.getStudentId(),
                "Activity Rejected",
                "Your activity \"" + s.getTitle() + "\" was rejected. Remarks: " + remarks,
                "REJECTED"
        );
        return s;
    }
}
