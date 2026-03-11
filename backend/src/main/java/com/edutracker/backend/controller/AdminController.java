package com.edutracker.backend.controller;

import com.edutracker.backend.model.User;
import com.edutracker.backend.repository.UserRepository;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/admin")
public class AdminController {

    @Autowired
    private UserRepository userRepository;

    @PostMapping("/add-fa")
    public String addFA(@RequestBody User newFA){

        if(userRepository.findByEmail(newFA.getEmail()).isPresent()){
            return "Email already exists";
        }

        newFA.setRole("FA");

        userRepository.save(newFA);

        return "FA added successfully";
    }

    @PostMapping("/add-student")
    public String addStudent(@RequestBody User newStudent){

        if(userRepository.findByEmail(newStudent.getEmail()).isPresent()){
            return "Email already exists";
        }

        newStudent.setRole("STUDENT");

        userRepository.save(newStudent);

        return "Student added successfully";
    }

    @GetMapping("/users")
    public List<User> getAllUsers(){
        return userRepository.findAll();
    }

    @GetMapping("/fa")
    public List<User> getFAByDept(@RequestParam String dept){

        return userRepository.findByRoleAndDept("FA", dept);
    }

    @DeleteMapping("/delete/{id}")
    public String deleteUser(@PathVariable Long id){

        if(!userRepository.existsById(id)){
        return "User not found";
    }

        userRepository.deleteById(id);

        return "User deleted successfully";
    }
}