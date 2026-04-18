package com.edutracker.backend.repository;

import com.edutracker.backend.model.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface UserRepository extends JpaRepository<User, Long> {

    // LOGIN
    Optional<User> findByEmailIgnoreCase(String email);

    // Used by AuthService (password encoder flow)
    Optional<User> findByEmail(String email);

    // PASSWORD RESET
    User findByResetToken(String token);

    // GET ALL USERS WITH A ROLE
    List<User> findByRole(String role);

    // GET FA BY DEPARTMENT
    List<User> findByRoleAndDept(String role, String dept);

    // GET USERS BY DEPARTMENT
    List<User> findByDept(String dept);

    // GET STUDENTS UNDER A FA
    List<User> findByFaId(Long faId);
}