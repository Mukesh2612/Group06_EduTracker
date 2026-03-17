package com.edutracker.backend.controller;

import com.edutracker.backend.model.ActivityCategory;
import com.edutracker.backend.service.ActivityCategoryService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/categories")
@CrossOrigin(origins="*")
public class ActivityCategoryController {

    private final ActivityCategoryService service;

    public ActivityCategoryController(ActivityCategoryService service) {
        this.service = service;
    }

    @GetMapping
    public List<ActivityCategory> getCategories() {
        return service.getAllCategories();
    }

    @PostMapping
    public ActivityCategory addCategory(@RequestBody ActivityCategory category) {
        return service.addCategory(category);
    }

    @PutMapping("/{id}")
    public ActivityCategory updateCategory(
            @PathVariable Long id,
            @RequestBody ActivityCategory category) {

        return service.updateCategory(id, category);
    }

    @DeleteMapping("/{id}")
    public void deleteCategory(@PathVariable Long id) {
        service.deleteCategory(id);
    }
}