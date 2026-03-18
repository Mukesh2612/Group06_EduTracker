package com.edutracker.backend.controller;

import com.edutracker.backend.model.User;
import com.edutracker.backend.repository.UserRepository;
import com.edutracker.backend.service.EmailService;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.*;

@CrossOrigin(origins = "*")
@RestController
@RequestMapping("/auth")
public class AuthController {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private EmailService emailService;

    /// ================= LOGIN =================
    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody User loginUser) {

        Optional<User> user = userRepository.findByEmailIgnoreCase(loginUser.getEmail().trim());

        if (user.isPresent() && user.get().getPassword().equals(loginUser.getPassword())) {

            User u = user.get();

            Map<String, Object> response = new HashMap<>();
            response.put("id", u.getId());
            response.put("role", u.getRole());
            response.put("name", u.getName());
            response.put("email", u.getEmail());
            response.put("dept", u.getDept());
            response.put("firstLogin", u.isFirstLogin());

            return ResponseEntity.ok(response);
        }

        return ResponseEntity.status(401).body("Invalid Credentials");
    }

    /// ================= CHANGE PASSWORD =================
    @PostMapping("/change-password")
    public ResponseEntity<?> changePassword(@RequestBody Map<String, String> data) {

        String email = data.get("email");
        String oldPass = data.get("oldPassword");
        String newPass = data.get("newPassword");

        User user = userRepository.findByEmailIgnoreCase(email.trim()).orElse(null);

        if (user == null) {
            return ResponseEntity.status(404).body("User not found");
        }

        if (!user.getPassword().equals(oldPass)) {
            return ResponseEntity.status(400).body("Wrong password");
        }

        user.setPassword(newPass);
        user.setFirstLogin(false);

        userRepository.save(user);

        return ResponseEntity.ok("Password updated successfully");
    }

    /// ================= FORGOT PASSWORD =================
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
        System.out.println("INPUT EMAIL: [" + email + "]");
        System.out.println("ALL USERS: " + userRepository.findAll());
       String resetLink = "http://localhost:8081/reset.html?token=" + token;

        // Send Email
        emailService.sendEmail(
                email,
                "Password Reset",
                "Click this link to reset your password:\n" + resetLink
        );

        return ResponseEntity.ok("Reset link sent to email");
    }

    /// ================= RESET PASSWORD =================
    @PostMapping("/reset-password")
    public ResponseEntity<?> resetPassword(@RequestBody Map<String, String> req) {

        String token = req.get("token");
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
}
