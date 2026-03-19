package com.edutracker.backend.repository;

import com.edutracker.backend.model.Submission;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Map;

public interface SubmissionRepository extends JpaRepository<Submission,Long>{

 List<Submission> findByStudentId(Long studentId);
 @Query("""
    SELECT s.id as id,
           s.title as title,
           s.category as category,
           s.points as points,
           s.status as status,
           s.remarks as remarks,
           s.proofFile as proofFile,
           u.name as studentName,
           u.rollNo as rollNo
    FROM Submission s
    JOIN User u ON s.studentId = u.id
    WHERE s.status = 'PENDING'
    """)
    List<Map<String,Object>> findPendingWithStudent();

    List<Submission> findByStatus(String status);

}