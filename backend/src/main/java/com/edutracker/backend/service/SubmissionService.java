package com.edutracker.backend.service;

import com.edutracker.backend.model.Submission;
import com.edutracker.backend.model.User;
import com.edutracker.backend.repository.SubmissionRepository;
import com.edutracker.backend.repository.UserRepository;
import org.springframework.stereotype.Service;
import java.util.Map;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

@Service
public class SubmissionService {

    private final SubmissionRepository repo;
    private final UserRepository userRepo;

    public SubmissionService(SubmissionRepository repo, UserRepository userRepo) {
        this.repo = repo;
        this.userRepo = userRepo;
    }

    // ========================
    // Student submits activity
    // ========================
    public Submission submit(Submission s) {

        s.setStatus("PENDING");
        return repo.save(s);
    }

    // ========================
    // Student activity history
    // ========================
    public List<Submission> studentSubmissions(Long id) {

        return repo.findByStudentId(id);
    }

    // ========================
    // FA view pending
    // ========================
    

    public List<Map<String, Object>> pendingWithStudent() {

    List<Map<String, Object>> list = new ArrayList<>();

    List<Submission> submissions = repo.findByStatus("PENDING");

    for (Submission s : submissions) {

        User student = userRepo.findById(s.getStudentId()).orElseThrow();

        Map<String, Object> data = new HashMap<>();

        data.put("id", s.getId());
        data.put("title", s.getTitle());
        data.put("category", s.getCategory());
        data.put("points", s.getPoints());
        data.put("proofFile", s.getProofFile());
        data.put("status", s.getStatus());

        data.put("studentName", student.getName());
        data.put("rollNo", student.getRollNo());

        list.add(data);
    }

    return list;
}

    // ========================
    // FA approve activity
    // ========================
    public Submission approve(Long id) {

        Submission s = repo.findById(id).orElseThrow();

        s.setStatus("APPROVED");

        User student = userRepo.findById(s.getStudentId()).orElseThrow();

        student.setTotalPoints(student.getTotalPoints() + s.getPoints());

        userRepo.save(student);

        return repo.save(s);
    }

    // ========================
    // FA reject activity
    // ========================
    public Submission reject(Long id, String remark) {

        Submission s = repo.findById(id).orElseThrow();

        s.setStatus("REJECTED");
        s.setRemarks(remark);

        return repo.save(s);
    }
}