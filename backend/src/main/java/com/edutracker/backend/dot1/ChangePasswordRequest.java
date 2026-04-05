package com.edutracker.backend.dto;

import jakarta.validation.constraints.*;

public class ChangePasswordRequest {

    @NotBlank(message = "Email is required")
    @Email(message = "Invalid email")
    private String email;

    @NotBlank(message = "Old password is required")
    private String oldPassword;

    @NotBlank(message = "New password is required")
    @Size(min = 8, message = "At least 8 characters")
    @Pattern(
        regexp = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@#$%^&+=!]).+$",
        message = "Must have uppercase, lowercase, number & special character"
    )
    private String newPassword;

    @NotBlank(message = "Please confirm your password")
    private String confirmPassword;

    // ── Getters ──────────────────────────
    public String getEmail()           { return email; }
    public String getOldPassword()     { return oldPassword; }
    public String getNewPassword()     { return newPassword; }
    public String getConfirmPassword() { return confirmPassword; }

    // ── Setters ──────────────────────────
    public void setEmail(String email)                     { this.email = email; }
    public void setOldPassword(String oldPassword)         { this.oldPassword = oldPassword; }
    public void setNewPassword(String newPassword)         { this.newPassword = newPassword; }
    public void setConfirmPassword(String confirmPassword) { this.confirmPassword = confirmPassword; }
}