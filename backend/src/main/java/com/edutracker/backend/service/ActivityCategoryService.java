package com.edutracker.backend.service;

import com.edutracker.backend.model.ActivityCategory;
import com.edutracker.backend.repository.ActivityCategoryRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class ActivityCategoryService {

    private final ActivityCategoryRepository repository;

    public ActivityCategoryService(ActivityCategoryRepository repository) {
        this.repository = repository;
    }

    public List<ActivityCategory> getAllCategories() {
        return repository.findAll();
    }

    public ActivityCategory addCategory(ActivityCategory category) {
        return repository.save(category);
    }

    public ActivityCategory updateCategory(Long id, ActivityCategory category) {

        ActivityCategory existing = repository.findById(id)
                .orElseThrow(() -> new RuntimeException("Category not found"));

        existing.setMain(category.getMain());     // ← ADDED
        existing.setTitle(category.getTitle());
        existing.setPoints(category.getPoints());
        existing.setType(category.getType());
        existing.setStatus(category.getStatus());

        return repository.save(existing);
    }

    public void deleteCategory(Long id) {
        repository.deleteById(id);
    }
}
