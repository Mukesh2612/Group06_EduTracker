package com.edutracker.backend.repository;

import com.edutracker.backend.model.Submission;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Map;

public interface SubmissionRepository extends JpaRepository<Submission, Long> {

    List<Submission> findByStudentId(Long studentId);

    // ✅ FIX: Use explicit AS aliases that EXACTLY match what Flutter reads.
    // Without aliases, Hibernate returns lowercase keys like "prooffile", "activitygroup"
    // which don't match Flutter's r['proofFile'], r['activityGroup'] → always null.
    @Query(value = """
        SELECT
            sub.id              AS id,
            sub.title           AS title,
            sub.level           AS level,
            sub.activity_group  AS activityGroup,
            sub.category        AS category,
            sub.points          AS points,
            sub.proof_file      AS proofFile,
            sub.status          AS status,
            sub.remarks         AS remarks,
            u.name              AS studentName,
            u.roll_no           AS rollNo,
            u.id                AS studentId
        FROM submissions sub
        JOIN users u ON sub.student_id = u.id
        WHERE sub.status = 'PENDING'
        ORDER BY sub.id DESC
    """, nativeQuery = true)
    List<Map<String, Object>> findPendingWithStudent();
}
