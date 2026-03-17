package com.edutracker.backend.controller;

import com.edutracker.backend.model.User;
import com.edutracker.backend.repository.UserRepository;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/student")
@CrossOrigin
public class StudentController {

    @Autowired
    private UserRepository userRepository;

    @GetMapping("/profile/{email}")
    public Map<String, Object> getStudentProfile(@PathVariable String email) {

        User student = userRepository.findByEmail(email).orElse(null);

        if (student == null) {
            return null;
        }

        User fa = null;

        if (student.getFaId() != null) {
            fa = userRepository.findById(student.getFaId()).orElse(null);
        }

        Map<String, Object> response = new HashMap<>();

        response.put("name", student.getName());
        response.put("rollNo", student.getRollNo());   
        response.put("email", student.getEmail());
        response.put("dept", student.getDept());
        response.put("points", student.getPoints());

        if (fa != null) {
            response.put("faName", fa.getName());
            response.put("faEmail", fa.getEmail());
        } else {
            response.put("faName", "Not Assigned");
            response.put("faEmail", "-");
        }

        return response;
    }
}