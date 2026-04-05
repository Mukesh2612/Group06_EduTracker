package com.edutracker.backend.repository;

import com.edutracker.backend.model.Notification;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

public interface NotificationRepository extends JpaRepository<Notification, Long> {

    // ── Student queries ───────────────────────────────────
    List<Notification> findByStudentIdOrderByCreatedAtDesc(Long studentId);

    long countByStudentIdAndIsReadFalse(Long studentId);

    @Modifying
    @Transactional
    @Query("UPDATE Notification n SET n.isRead = true WHERE n.studentId = :studentId")
    void markAllAsReadByStudentId(Long studentId);

    // ── FA queries ────────────────────────────────────────
    List<Notification> findByFaIdOrderByCreatedAtDesc(Long faId);

    long countByFaIdAndIsReadFalse(Long faId);

    @Modifying
    @Transactional
    @Query("UPDATE Notification n SET n.isRead = true WHERE n.faId = :faId")
    void markAllAsReadByFaId(Long faId);
}