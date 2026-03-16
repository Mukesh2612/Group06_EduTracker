package com.edutracker.backend.service;

import com.edutracker.backend.model.User;
import com.edutracker.backend.repository.UserRepository;
import org.springframework.stereotype.Service;
import java.util.Optional;


@Service
public class AuthService {

 private final UserRepository repo;

 public AuthService(UserRepository repo){
  this.repo = repo;
 }

 public User login(String email, String password){

 Optional<User> optionalUser = repo.findByEmail(email);

 if(optionalUser.isPresent()){
  User user = optionalUser.get();

  if(user.getPassword().equals(password)){
   return user;
  }
 }

 return null;
}


public String changePassword(String email,String oldPass,String newPass){

 Optional<User> optionalUser = repo.findByEmail(email);

 if(optionalUser.isEmpty())
  return "User not found";

 User user = optionalUser.get();

 if(!user.getPassword().equals(oldPass))
  return "Old password incorrect";

 user.setPassword(newPass);
 repo.save(user);

 return "Password updated";
}
}