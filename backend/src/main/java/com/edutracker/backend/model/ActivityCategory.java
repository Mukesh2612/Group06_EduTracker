package com.edutracker.backend.model;

import jakarta.persistence.*;

@Entity
@Table(name = "categories")
public class ActivityCategory {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String main;    // Group name (e.g. "Sports", "Cultural")
    private String title;   // Activity name
    private int points;
    private String type;    // "institute" or "department"
    private String status;  // "active" or "inactive"

    // ================= Getters =================

    public Long getId()       { return id; }
    public String getMain()   { return main; }
    public String getTitle()  { return title; }
    public int getPoints()    { return points; }
    public String getType()   { return type; }
    public String getStatus() { return status; }

    // ================= Setters =================

    public void setId(Long id)           { this.id = id; }
    public void setMain(String main)     { this.main = main; }
    public void setTitle(String title)   { this.title = title; }
    public void setPoints(int points)    { this.points = points; }
    public void setType(String type)     { this.type = type; }
    public void setStatus(String status) { this.status = status; }
}
