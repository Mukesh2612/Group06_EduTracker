package com.edutracker.backend.controller;

import com.edutracker.backend.model.ActivityCategory;
import com.edutracker.backend.repository.ActivityCategoryRepository;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@CrossOrigin(origins = "*")
@RestController
@RequestMapping("/api/categories")
public class CategoryController {

    @Autowired
    private ActivityCategoryRepository categoryRepository;

    // ================= GET ALL =================
    @GetMapping
    public List<ActivityCategory> getAllCategories() {
        return categoryRepository.findAll();
    }

    // ================= ADD =================
    @PostMapping
    public ResponseEntity<ActivityCategory> addCategory(@RequestBody ActivityCategory category) {
        ActivityCategory saved = categoryRepository.save(category);
        return ResponseEntity.ok(saved);
    }

    // ================= UPDATE =================
    @PutMapping("/{id}")
    public ResponseEntity<?> updateCategory(@PathVariable Long id, @RequestBody ActivityCategory category) {

        if (!categoryRepository.existsById(id)) {
            return ResponseEntity.status(404).body("Category not found");
        }

        category.setId(id);
        ActivityCategory updated = categoryRepository.save(category);
        return ResponseEntity.ok(updated);
    }

    // ================= DELETE =================
    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteCategory(@PathVariable Long id) {

        if (!categoryRepository.existsById(id)) {
            return ResponseEntity.status(404).body("Category not found");
        }

        categoryRepository.deleteById(id);
        return ResponseEntity.ok("Deleted successfully");
    }
}