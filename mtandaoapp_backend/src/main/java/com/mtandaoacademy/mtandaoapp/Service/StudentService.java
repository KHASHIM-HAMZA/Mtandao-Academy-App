package com.mtandaoacademy.mtandaoapp.Service;

import com.mtandaoacademy.mtandaoapp.DTO.StudentProfileDTO;
import com.mtandaoacademy.mtandaoapp.Model.Student;
import com.mtandaoacademy.mtandaoapp.Model.User;
import com.mtandaoacademy.mtandaoapp.Repository.UserRepo.StudentRepository;
import com.mtandaoacademy.mtandaoapp.Repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;

@Service
public class StudentService {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private StudentRepository studentRepository;

    public Map<String, Object> getStudentProfile(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        Student student = user.getStudent();
        if (student == null) {
            throw new RuntimeException("Student profile not found");
        }

        Map<String, Object> profile = new HashMap<>();
        profile.put("id", user.getId());
        profile.put("name", user.getName());
        profile.put("email", user.getEmail());
        profile.put("phone", user.getPhoneNumber());
        profile.put("profilePhoto", user.getProfilePhoto());
        profile.put("school", student.getSchool());
        profile.put("level", student.getLevel());
        profile.put("subLevel", student.getSub_level());
        profile.put("joinDate", user.getCreatedAt());

        return profile;
    }

    public Map<String, Object> getDashboardData(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        Student student = user.getStudent();
        if (student == null) {
            throw new RuntimeException("Student profile not found");
        }

        Map<String, Object> dashboard = new HashMap<>();

        // Student profile info
        dashboard.put("studentName", user.getName());
        dashboard.put("level", student.getLevel());
        dashboard.put("subLevel", student.getSub_level());
        dashboard.put("school", student.getSchool());

        // Mock statistics - replace with actual data from your database
        dashboard.put("completedAssignments", 12);
        dashboard.put("upcomingExams", 3);
        dashboard.put("resourcesDownloaded", 25);
        dashboard.put("averageScore", 78.5);
        dashboard.put("attendanceRate", 95.2);

        return dashboard;
    }

    public Map<String, Object> updateStudentProfile(Long userId, StudentProfileDTO studentProfileDTO) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        Student student = user.getStudent();
        if (student == null) {
            throw new RuntimeException("Student profile not found");
        }

        // Check if email is being changed and if it's already taken by another user
        if (!user.getEmail().equals(studentProfileDTO.getEmail())) {
            boolean emailExists = userRepository.findByEmail(studentProfileDTO.getEmail())
                    .filter(existingUser -> !existingUser.getId().equals(userId))
                    .isPresent();

            if (emailExists) {
                throw new RuntimeException("Email is already taken by another user");
            }
        }

        // Update user details
        user.setName(studentProfileDTO.getName());
        user.setEmail(studentProfileDTO.getEmail());
        user.setPhoneNumber(studentProfileDTO.getPhoneNumber());

        // Update student details
        student.setSchool(studentProfileDTO.getSchool());
        student.setLevel(studentProfileDTO.getLevel());
        student.setSub_level(studentProfileDTO.getSub_level());

        // Save changes
        userRepository.save(user);
        studentRepository.save(student);

        // Return updated profile
        return getStudentProfile(userId);
    }
}