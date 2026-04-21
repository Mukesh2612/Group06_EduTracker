package com.edutracker.backend.controller;

import com.edutracker.backend.model.User;
import com.edutracker.backend.repository.UserRepository;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@CrossOrigin(origins = "*")
@RestController
@RequestMapping("/admin")   // FIXED: was /auth in friend's original, corrected to /admin
public class AdminController {

    @Autowired
    private UserRepository userRepository;

    // ================= ADD FA =================
    @PostMapping("/add-fa")
    public String addFA(@RequestBody User newFA) {

        if (userRepository.findByEmailIgnoreCase(newFA.getEmail().trim()).isPresent()) {
            return "Email already exists";
        }
        if (newFA.getEmpId() == null || newFA.getEmpId().isEmpty()) {
            return "Employee ID required for FA";
        }
        if (newFA.getDept() == null || newFA.getDept().isEmpty()) {
            return "Department required for FA";
        }

        newFA.setRole("FA");
        newFA.setRollNo(null);
        newFA.setFaId(null);
        newFA.setPoints(0);

        userRepository.save(newFA);
        return "FA added successfully";
    }

    // ================= ADD ADMIN =================
    @PostMapping("/add-admin")
    public String addAdmin(@RequestBody User admin) {

        if (userRepository.findByEmailIgnoreCase(admin.getEmail().trim()).isPresent()) {
            return "Email already exists";
        }

        admin.setRole("ADMIN");
        admin.setEmpId(null);
        admin.setRollNo(null);
        admin.setFaId(null);

        userRepository.save(admin);
        return "Admin added successfully";
    }

    // ================= ADD STUDENT =================
    @PostMapping("/add-student")
    public String addStudent(@RequestBody User newStudent) {

        if (userRepository.findByEmailIgnoreCase(newStudent.getEmail().trim()).isPresent()) {
            return "Email already exists";
        }
        if (newStudent.getRollNo() == null || newStudent.getRollNo().isEmpty()) {
            return "Roll number required";
        }
        if (newStudent.getFaId() == null) {
            return "FA required";
        }
        if (newStudent.getDept() == null || newStudent.getDept().isEmpty()) {
            return "Department required";
        }

        newStudent.setRole("STUDENT");
        newStudent.setEmpId(null);

        // Default password = roll number (uppercase)
        newStudent.setPassword(newStudent.getRollNo().toUpperCase());
        newStudent.setFirstLogin(true);

        userRepository.save(newStudent);
        return "Student added successfully";
    }

    // ================= GET STUDENTS UNDER FA =================
    @GetMapping("/students/{faId}")
    public List<User> getStudentsByFa(@PathVariable Long faId) {
        return userRepository.findByFaId(faId)
                .stream()
                .filter(u -> "STUDENT".equals(u.getRole()))
                .toList();
    }

    // ================= GET ALL USERS =================
    @GetMapping("/users")
    public List<User> getAllUsers() {
        return userRepository.findAll();
    }

    // ================= GET FA BY DEPT =================
    @GetMapping("/fa")
    public List<User> getFAByDept(@RequestParam String dept) {
        return userRepository.findByRoleAndDept("FA", dept);
    }

    // ================= DELETE USER =================
    @DeleteMapping("/delete/{id}")
    public String deleteUser(@PathVariable Long id) {

        if (!userRepository.existsById(id)) {
            return "User not found";
        }

        userRepository.deleteById(id);
        return "User deleted successfully";
    }
}
