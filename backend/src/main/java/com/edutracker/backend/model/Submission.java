package com.edutracker.backend.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "submissions")
public class Submission {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "student_id")
    private Long studentId;

    private String title;
    private String level;

    @Column(name = "activity_group")
    private String activityGroup;

    private String category;
    private int points;

    @Column(name = "proof_file")
    private String proofFile;

    private String status;
    private String remarks;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    // ✅ NEW: Prevents duplicate notifications/emails on re-click
    @Column(name = "review_notification_sent", nullable = false, columnDefinition = "BOOLEAN DEFAULT false")
    private boolean reviewNotificationSent = false;

    @PrePersist
    public void setCreatedAt() {
        this.createdAt = LocalDateTime.now();
    }

    // ================= GETTERS & SETTERS =================

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getStudentId() { return studentId; }
    public void setStudentId(Long studentId) { this.studentId = studentId; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getLevel() { return level; }
    public void setLevel(String level) { this.level = level; }

    public String getActivityGroup() { return activityGroup; }
    public void setActivityGroup(String activityGroup) { this.activityGroup = activityGroup; }

    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }

    public int getPoints() { return points; }
    public void setPoints(int points) { this.points = points; }

    public String getProofFile() { return proofFile; }
    public void setProofFile(String proofFile) { this.proofFile = proofFile; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getRemarks() { return remarks; }
    public void setRemarks(String remarks) { this.remarks = remarks; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    // ✅ NEW GETTER/SETTER
    public boolean isReviewNotificationSent() { return reviewNotificationSent; }
    public void setReviewNotificationSent(boolean reviewNotificationSent) {
        this.reviewNotificationSent = reviewNotificationSent;
    }
}
