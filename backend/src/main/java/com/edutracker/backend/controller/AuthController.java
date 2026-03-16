package com.edutracker.backend.controller;

import com.edutracker.backend.model.User;
import com.edutracker.backend.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.Optional;


@RestController
@RequestMapping("/auth")
public class AuthController {

    @Autowired
    private UserRepository userRepository;

    @PostMapping("/login")
    public String login(@RequestBody User loginUser) {

        Optional<User> user = userRepository.findByEmail(loginUser.getEmail());

        if (user.isPresent() && user.get().getPassword().equals(loginUser.getPassword())) {
            return "Login Success: " + user.get().getRole();
        }

        return "Invalid Credentials";
    }

    @PostMapping("/change-password")
public String changePassword(@RequestBody User reqUser) {

    Optional<User> userOpt = userRepository.findByEmail(reqUser.getEmail());

    if(userOpt.isEmpty()){
        return "User not found";
    }

    User user = userOpt.get();

    if(!user.getPassword().equals(reqUser.getPassword())){
        return "Old password incorrect";
    }

    user.setPassword(reqUser.getNewPassword());
    userRepository.save(user);

    return "Password updated successfully";
}
}