package com.edutracker.backend.controller;

import com.edutracker.backend.model.User;
import com.edutracker.backend.repository.UserRepository;
import com.edutracker.backend.repository.SubmissionRepository;
import com.edutracker.backend.service.EmailService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseToken;
import org.springframework.http.HttpStatus;
import java.time.LocalDateTime;
import java.util.*;

@CrossOrigin(origins = "*")
@RestController
@RequestMapping("/auth")
public class AuthController {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private SubmissionRepository submissionRepository;

    @Autowired
    private EmailService emailService;

    // ================= LOGIN =================
    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody Map<String, String> request) {

        String email    = request.get("email");
        String password = request.get("password");
        String fcmToken = request.get("fcmToken");

        Optional<User> userOpt = userRepository.findByEmailIgnoreCase(email.trim());

        if (userOpt.isPresent() && userOpt.get().getPassword().equals(password)) {

            User user = userOpt.get();

            if (fcmToken != null) {
                user.setFcmToken(fcmToken);
                userRepository.save(user);
            }

            Map<String, Object> response = new HashMap<>();
            response.put("id",         user.getId());
            response.put("role",       user.getRole());
            response.put("name",       user.getName());
            response.put("email",      user.getEmail());
            response.put("dept",       user.getDept());
            response.put("firstLogin", user.isFirstLogin());

            return ResponseEntity.ok(response);
        }

        return ResponseEntity.status(401).body("Invalid Credentials");
    }

    // ================= CHANGE PASSWORD =================
    @PostMapping("/change-password")
    public ResponseEntity<?> changePassword(@RequestBody Map<String, String> data) {

        String email   = data.get("email");
        String oldPass = data.get("oldPassword");
        String newPass = data.get("newPassword");

        if (newPass == null || newPass.length() < 8) {
            return ResponseEntity.badRequest().body("Password must be at least 8 characters");
        }
        if (!newPass.matches(".*[A-Z].*")) {
            return ResponseEntity.badRequest().body("Password must contain at least one uppercase letter");
        }
        if (!newPass.matches(".*[a-z].*")) {
            return ResponseEntity.badRequest().body("Password must contain at least one lowercase letter");
        }
        if (!newPass.matches(".*[0-9].*")) {
            return ResponseEntity.badRequest().body("Password must contain at least one number");
        }
        if (!newPass.matches(".*[!@#$%^&*()\\-_=+\\[\\]{};:,.<>?/`~|\\\\].*")) {
            return ResponseEntity.badRequest().body("Password must contain at least one special character");
        }

        User user = userRepository.findByEmailIgnoreCase(email.trim()).orElse(null);

        if (user == null) {
            return ResponseEntity.status(404).body("User not found");
        }

        if (!user.getPassword().equals(oldPass)) {
            return ResponseEntity.status(400).body("Wrong old password");
        }

        user.setPassword(newPass);
        user.setFirstLogin(false);
        userRepository.save(user);

        return ResponseEntity.ok("Password updated successfully");
    }

    // ================= FORGOT PASSWORD =================
    @PostMapping("/forgot-password")
    public ResponseEntity<?> forgotPassword(@RequestBody Map<String, String> req) {

        String email = req.get("email");

        User user = userRepository.findAll()
                .stream()
                .filter(u -> u.getEmail() != null &&
                             u.getEmail().equalsIgnoreCase(email.trim()))
                .findFirst()
                .orElse(null);

        if (user == null) {
            return ResponseEntity.badRequest().body("User not found");
        }

        String token = UUID.randomUUID().toString();
        user.setResetToken(token);
        user.setTokenExpiry(LocalDateTime.now().plusMinutes(30));
        userRepository.save(user);

        String resetLink = "http://localhost:8081/reset.html?token=" + token;

        emailService.sendEmail(
                email,
                "Password Reset",
                "Click this link to reset your password:\n" + resetLink
        );

        return ResponseEntity.ok("Reset link sent to email");
    }

    // ================= RESET PASSWORD =================
    @PostMapping("/reset-password")
    public ResponseEntity<?> resetPassword(@RequestBody Map<String, String> req) {

        String token       = req.get("token");
        String newPassword = req.get("password");

        User user = userRepository.findByResetToken(token);

        if (user == null) {
            return ResponseEntity.badRequest().body("Invalid token");
        }

        if (user.getTokenExpiry().isBefore(LocalDateTime.now())) {
            return ResponseEntity.badRequest().body("Token expired");
        }

        user.setPassword(newPassword);
        user.setResetToken(null);
        user.setTokenExpiry(null);
        userRepository.save(user);

        return ResponseEntity.ok("Password updated successfully");
    }

    // ================= STUDENT PROFILE =================
    @GetMapping("/student/profile/{email}")
    public ResponseEntity<?> getStudentProfile(@PathVariable String email) {

        User student = userRepository.findByEmailIgnoreCase(email).orElse(null);

        if (student == null) {
            return ResponseEntity.status(404).body("Student not found");
        }

        User fa = null;
        if (student.getFaId() != null) {
            fa = userRepository.findById(student.getFaId()).orElse(null);
        }

        Map<String, Object> response = new HashMap<>();
        response.put("id",      student.getId());
        response.put("name",    student.getName());
        response.put("rollNo",  student.getRollNo());
        response.put("email",   student.getEmail());
        response.put("dept",    student.getDept());
        response.put("points",  student.getPoints());
        response.put("faName",  fa != null ? fa.getName()  : "");
        response.put("faEmail", fa != null ? fa.getEmail() : "");

        // ✅ Count submissions for this student
        var allSubs = submissionRepository.findByStudentId(student.getId());
        long submittedCount = allSubs.size();
        long approvedCount  = allSubs.stream()
                .filter(s -> "APPROVED".equals(s.getStatus()))
                .count();
        response.put("submitted", submittedCount);
        response.put("approved",  approvedCount);

        return ResponseEntity.ok(response);
    }

    // ================= GOOGLE LOGIN =================
    @PostMapping("/google")
    public ResponseEntity<?> googleLogin(@RequestBody Map<String, String> body) {

        String idToken = body.get("token");

        try {
            FirebaseToken decodedToken =
                    FirebaseAuth.getInstance().verifyIdToken(idToken);

            String email = decodedToken.getEmail();

            // Only allow existing users — no auto-registration
            Optional<User> userOpt = userRepository.findByEmailIgnoreCase(email);

            if (userOpt.isEmpty()) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN)
                        .body("Access denied. Your email is not registered in the system.");
            }

            User user = userOpt.get();

            Map<String, Object> response = new HashMap<>();
            response.put("id",    user.getId());
            response.put("role",  user.getRole());
            response.put("name",  user.getName());
            response.put("email", user.getEmail());
            response.put("dept",  user.getDept());

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Invalid token");
        }
    }
}