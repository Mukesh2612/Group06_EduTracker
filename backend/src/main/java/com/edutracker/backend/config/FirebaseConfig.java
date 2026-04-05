package com.edutracker.backend.config;
import java.io.FileInputStream;
import java.io.InputStream; 
import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;

import org.springframework.context.annotation.Configuration;
import jakarta.annotation.PostConstruct;
@Configuration
public class FirebaseConfig {

   @PostConstruct
public void init() {
    try {
        if (FirebaseApp.getApps().isEmpty()) {
            InputStream serviceAccount =
                getClass().getClassLoader()
                    .getResourceAsStream("serviceAccountKey.json");

            // ADD THIS CHECK:
            if (serviceAccount == null) {
                System.out.println("❌ serviceAccountKey.json NOT FOUND in classpath!");
                return;
            }

            FirebaseOptions options = FirebaseOptions.builder()
                .setCredentials(GoogleCredentials.fromStream(serviceAccount))
                .build();

            FirebaseApp.initializeApp(options);
            System.out.println("✅ Firebase initialized successfully");
        } else {
            System.out.println("⚠️ Firebase already initialized");
        }
    } catch (Exception e) {
        System.out.println("❌ Firebase init failed: " + e.getMessage());
        e.printStackTrace();
    }
}
}