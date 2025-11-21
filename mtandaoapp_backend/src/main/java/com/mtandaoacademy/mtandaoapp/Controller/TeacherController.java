// TeacherController.java
package com.mtandaoacademy.mtandaoapp.Controller;

import com.mtandaoacademy.mtandaoapp.DTO.TeacherProfileDTO;
import com.mtandaoacademy.mtandaoapp.DTO.TeacherUpdateDTO;
import com.mtandaoacademy.mtandaoapp.Model.Teacher;
import com.mtandaoacademy.mtandaoapp.Model.User;
import com.mtandaoacademy.mtandaoapp.Repository.UserRepo.TeacherRepository;
import com.mtandaoacademy.mtandaoapp.Repository.UserRepository;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/teacher")
public class TeacherController {

    private final TeacherRepository teacherRepository;
    private final UserRepository userRepository;

    public TeacherController(TeacherRepository teacherRepository, UserRepository userRepository) {
        this.teacherRepository = teacherRepository;
        this.userRepository = userRepository;
    }

    @GetMapping("/me")
    public ResponseEntity<?> getProfile(@AuthenticationPrincipal UserDetails userDetails) {
        var user = userRepository.findByEmail(userDetails.getUsername())
                .orElseThrow(() -> new RuntimeException("User not found"));

        var teacher = teacherRepository.findById(user.getId())
                .orElseThrow(() -> new RuntimeException("Teacher not found"));

        TeacherProfileDTO dto = new TeacherProfileDTO();
        dto.setId(user.getId());
        dto.setName(user.getName());
        dto.setEmail(user.getEmail());
        dto.setPhoneNumber(user.getPhoneNumber());
        dto.setSchool(teacher.getSchool());
        dto.setQualification(teacher.getQualification());
        dto.setExperience(teacher.getExperience());
        dto.setSubjects(teacher.getSubjects());
        dto.setJoinDate(teacher.getJoinDate());

        return ResponseEntity.ok(dto);
    }

    @PutMapping("/profile")
    public ResponseEntity<?> updateProfile(
            @Valid @RequestBody TeacherUpdateDTO updateDTO,
            @AuthenticationPrincipal UserDetails userDetails) {

        try {
            // Find the user
            User user = userRepository.findByEmail(userDetails.getUsername())
                    .orElseThrow(() -> new RuntimeException("User not found"));

            // Find the teacher
            Teacher teacher = teacherRepository.findById(user.getId())
                    .orElseThrow(() -> new RuntimeException("Teacher not found"));

            // Update user fields (except name)
            if (updateDTO.getEmail() != null) {
                user.setEmail(updateDTO.getEmail());
            }
            if (updateDTO.getPhoneNumber() != null) {
                user.setPhoneNumber(updateDTO.getPhoneNumber());
            }

            // Update teacher fields
            if (updateDTO.getSchool() != null) {
                teacher.setSchool(updateDTO.getSchool());
            }
            if (updateDTO.getQualification() != null) {
                teacher.setQualification(updateDTO.getQualification());
            }
            if (updateDTO.getExperience() != null) {
                teacher.setExperience(updateDTO.getExperience());
            }

            // Save changes
            userRepository.save(user);
            teacherRepository.save(teacher);

            // Return updated profile
            TeacherProfileDTO responseDTO = new TeacherProfileDTO();
            responseDTO.setId(user.getId());
            responseDTO.setName(user.getName()); // Name remains unchanged
            responseDTO.setEmail(user.getEmail());
            responseDTO.setPhoneNumber(user.getPhoneNumber());
            responseDTO.setSchool(teacher.getSchool());
            responseDTO.setQualification(teacher.getQualification());
            responseDTO.setExperience(teacher.getExperience());
            responseDTO.setSubjects(teacher.getSubjects());
            responseDTO.setJoinDate(teacher.getJoinDate()); // Join date remains unchanged

            return ResponseEntity.ok(responseDTO);

        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Error updating profile: " + e.getMessage());
        }
    }
}