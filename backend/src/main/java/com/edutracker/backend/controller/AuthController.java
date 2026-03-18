
package com.edutracker.backend.controller;

import com.edutracker.backend.model.User;
import com.edutracker.backend.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

@CrossOrigin(origins = "*")
@RestController
@RequestMapping("/auth")
public class AuthController {

    @Autowired
    private UserRepository userRepository;

    /// ================= LOGIN =================
    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody User loginUser) {

        Optional<User> user = userRepository.findByEmail(loginUser.getEmail());

        if(user.isPresent() && user.get().getPassword().equals(loginUser.getPassword())) {

            User u = user.get();

            Map<String,Object> response = new HashMap<>();

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

        User user = userRepository.findByEmail(email).orElse(null);

        if(user == null){
            return ResponseEntity.status(404).body("User not found");
        }

        if(!user.getPassword().equals(oldPass)){
            return ResponseEntity.status(400).body("Wrong password");
        }

        user.setPassword(newPass);
        user.setFirstLogin(false); 

        userRepository.save(user);

        return ResponseEntity.ok("Password updated successfully");
    }
}

