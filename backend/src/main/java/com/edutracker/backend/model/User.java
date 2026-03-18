package com.edutracker.backend.model;

import java.time.LocalDateTime;
import jakarta.persistence.*;

@Entity
@Table(name="users")
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;
    private String email;
    private String password;
    private String role;
    private String dept;
    private String rollNo;
    private String empId;
    private Long faId;
    private int points;

    // 🔐 Forgot password fields
    private String resetToken;
    private LocalDateTime tokenExpiry;

    // ⭐ First login check
    private boolean firstLogin = true;
    @Override
    public String toString() {
    return "User{" +
            "id=" + id +
            ", email='" + email + '\'' +
            '}';
    }
    public User() {}

    // ── id ──────────────────────────────────────────
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    // ── name ────────────────────────────────────────
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    // ── email ───────────────────────────────────────
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    // ── password ────────────────────────────────────
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    // ── role ────────────────────────────────────────
    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }

    // ── dept ────────────────────────────────────────
    public String getDept() { return dept; }
    public void setDept(String dept) { this.dept = dept; }

    // ── rollNo ──────────────────────────────────────
    public String getRollNo() { return rollNo; }
    public void setRollNo(String rollNo) { this.rollNo = rollNo; }

    // ── empId ───────────────────────────────────────
    public String getEmpId() { return empId; }
    public void setEmpId(String empId) { this.empId = empId; }

    // ── faId ────────────────────────────────────────
    public Long getFaId() { return faId; }
    public void setFaId(Long faId) { this.faId = faId; }

    // ── points ──────────────────────────────────────
    public int getPoints() { return points; }
    public void setPoints(int points) { this.points = points; }

    // ── firstLogin ──────────────────────────────────
    public boolean isFirstLogin() { return firstLogin; }
    public void setFirstLogin(boolean firstLogin) { this.firstLogin = firstLogin; }

    // 🔐 ── resetToken ───────────────────────────────
    public String getResetToken() { return resetToken; }
    public void setResetToken(String resetToken) { this.resetToken = resetToken; }

    // 🔐 ── tokenExpiry ──────────────────────────────
    public LocalDateTime getTokenExpiry() { return tokenExpiry; }
    public void setTokenExpiry(LocalDateTime tokenExpiry) { this.tokenExpiry = tokenExpiry; }
}
