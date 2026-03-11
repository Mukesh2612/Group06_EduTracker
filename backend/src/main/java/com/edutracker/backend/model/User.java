package com.edutracker.backend.model;

import jakarta.persistence.*;

@Entity
@Table(name = "Users")
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;

    @Column(unique = true)
    private String email;

    private String password;
    private String role;

    private String dept;
    private String rollNo;

    private Long faId;

    // ID
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    // NAME
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    // EMAIL
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    // PASSWORD
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    // ROLE
    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }

    // DEPARTMENT
    public String getDept() { return dept; }
    public void setDept(String dept) { this.dept = dept; }

    // ROLL NUMBER
    public String getRollNo() { return rollNo; }
    public void setRollNo(String rollNo) { this.rollNo = rollNo; }

    // FACULTY ADVISOR ID
    public Long getFaId() { return faId; }
    public void setFaId(Long faId) { this.faId = faId; }
}