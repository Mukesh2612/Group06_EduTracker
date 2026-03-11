package com.edutracker.backend.model;

import jakarta.persistence.*;

@Entity
@Table(name = "Users")
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String name;

    @Column(nullable = false, unique = true)
    private String email;

    @Column(nullable = false)
    private String password;

    @Column(nullable = false)
    private String role;

    private String dept;

    @Column(unique = true)
    private String rollNo;

    @Column(unique = true)
    private String empId;

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

    // EMP ID
    public String getEmpId() { return empId; }
    public void setEmpId(String empId) { this.empId = empId; }

    // FACULTY ADVISOR ID
    public Long getFaId() { return faId; }
    public void setFaId(Long faId) { this.faId = faId; }
}