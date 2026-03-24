package com.edutracker.backend.model;

import jakarta.persistence.*;

@Entity
@Table(name = "activity_categories")
public class ActivityCategory {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String title;
    private Integer points;
    private String type;   
    private String status; 

    public ActivityCategory() {}

    public Long getId() {
        return id;
    }

    public String getTitle() {
        return title;
    }

    public Integer getPoints() {
        return points;
    }

    public String getType() {
        return type;
    }

    public String getStatus() {
        return status;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public void setPoints(Integer points) {
        this.points = points;
    }

    public void setType(String type) {
        this.type = type;
    }

    public void setStatus(String status) {
        this.status = status;
    }
}