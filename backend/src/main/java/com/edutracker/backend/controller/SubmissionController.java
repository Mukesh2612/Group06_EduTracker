package com.edutracker.backend.controller;

import com.edutracker.backend.model.Submission;
import com.edutracker.backend.service.SubmissionService;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/submissions")
@CrossOrigin
public class SubmissionController {

 private final SubmissionService service;

 public SubmissionController(SubmissionService service){
  this.service = service;
 }

 @PostMapping("/submit")
 public Submission submit(@RequestBody Submission s){
  return service.submit(s);
 }

 @GetMapping("/student/{id}")
 public List<Submission> student(@PathVariable Long id){
  return service.studentSubmissions(id);
 }

 @GetMapping("/pending")
 public List<Map<String,Object>> pending(){
    return service.pendingWithStudent();
}
 @PostMapping("/approve/{id}")
 public Submission approve(@PathVariable Long id){
  return service.approve(id);
 }

 @PutMapping("/reject/{id}")
 public Submission reject(@PathVariable Long id,@RequestParam String remarks){
  return service.reject(id,remarks);
 }

}