package com.edutracker.backend.repository;

import com.edutracker.backend.model.ActivityCategory;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ActivityCategoryRepository
        extends JpaRepository<ActivityCategory, Long> {
}