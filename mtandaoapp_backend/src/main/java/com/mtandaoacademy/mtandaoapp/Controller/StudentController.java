package com.mtandaoacademy.mtandaoapp.Controller;

import com.mtandaoacademy.mtandaoapp.DTO.StudentProfileDTO;
import com.mtandaoacademy.mtandaoapp.Repository.UserRepository;
import com.mtandaoacademy.mtandaoapp.Service.StudentService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;


import java.util.Map;

@RestController
@RequestMapping("/api/student")
@CrossOrigin(origins = "*") // Adjust based on your frontend URL
public class StudentController {

    @Autowired
    private StudentService studentService;

    @Autowired
    private UserRepository userRepository;

    @GetMapping("/me")
    public ResponseEntity<?> getStudentProfile(@AuthenticationPrincipal UserDetails userDetails) {
        try {
            var user = userRepository.findByEmail(userDetails.getUsername())
                    .orElseThrow(() -> new RuntimeException("User not found"));

            if (user.getStudent() == null) {
                return ResponseEntity.badRequest().body(Map.of("error", "User is not a student"));
            }

            return ResponseEntity.ok(studentService.getStudentProfile(user.getId()));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    @GetMapping("/dashboard")
    public ResponseEntity<?> getDashboardData(@AuthenticationPrincipal UserDetails userDetails) {
        try {
            var user = userRepository.findByEmail(userDetails.getUsername())
                    .orElseThrow(() -> new RuntimeException("User not found"));

            if (user.getStudent() == null) {
                return ResponseEntity.badRequest().body(Map.of("error", "User is not a student"));
            }

            return ResponseEntity.ok(studentService.getDashboardData(user.getId()));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    @PutMapping("/profile")
    public ResponseEntity<?> updateStudentProfile(
            @AuthenticationPrincipal UserDetails userDetails,
            @Valid @RequestBody StudentProfileDTO studentProfileDTO) {
        try {
            var user = userRepository.findByEmail(userDetails.getUsername())
                    .orElseThrow(() -> new RuntimeException("User not found"));

            if (user.getStudent() == null) {
                return ResponseEntity.badRequest().body(Map.of("error", "User is not a student"));
            }

            // Update student profile
            Map<String, Object> updatedProfile = studentService.updateStudentProfile(user.getId(), studentProfileDTO);

            return ResponseEntity.ok(Map.of(
                    "message", "Profile updated successfully",
                    "profile", updatedProfile
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }
}