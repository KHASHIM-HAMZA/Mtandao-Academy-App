package com.mtandaoacademy.mtandaoapp.Service;



import com.mtandaoacademy.mtandaoapp.DTO.UserDTO;
import com.mtandaoacademy.mtandaoapp.Model.Enums.Role;
import com.mtandaoacademy.mtandaoapp.Model.Student;
import com.mtandaoacademy.mtandaoapp.Model.Teacher;
import com.mtandaoacademy.mtandaoapp.Model.User;
import com.mtandaoacademy.mtandaoapp.Repository.UserRepo.StudentRepository;
import com.mtandaoacademy.mtandaoapp.Repository.UserRepo.TeacherRepository;
import com.mtandaoacademy.mtandaoapp.Repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;
import java.util.Optional;

@Service
public class UserService {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private StudentRepository studentRepository;

    @Autowired
    private TeacherRepository teacherRepository;

    private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    public ResponseEntity<List<UserDTO>> getAllUser() {
        List<UserDTO> users = userRepository.findAll().stream().map(user -> {
            if (user.getRole() == Role.STUDENT && user.getStudent() != null) {
                return new UserDTO(
                        user.getId(),
                        user.getName(),
                        user.getEmail(),
                        user.getPhoneNumber(),
                        user.getRole(),
                        Map.of(
                                "school", user.getStudent().getSchool(),
                                "level", user.getStudent().getLevel()
                        )
                );
            } else if (user.getRole() == Role.TEACHER && user.getTeacher() != null) {
                return new UserDTO(
                        user.getId(),
                        user.getName(),
                        user.getEmail(),
                        user.getPhoneNumber(),
                        user.getRole(),
                        Map.of(
                                "school", user.getTeacher().getSchool(),
                                "specialization", user.getTeacher().getSpecialization()
                        )
                );
            } else {
                return new UserDTO(
                        user.getId(),
                        user.getName(),
                        user.getEmail(),
                        user.getPhoneNumber(),
                        user.getRole(),
                        null
                );
            }
        }).toList();
        return ResponseEntity.ok(users);

    }

    // ---------------- NORMAL REGISTRATION ----------------
    public User registerUser(User user, String school, String level, String specialization, String department, String registrationNumber) {
        if (userRepository.findByEmail(user.getEmail()).isPresent()) {
            throw new RuntimeException("Email already registered!");
        }

        // Hash password
        user.setPassword(passwordEncoder.encode(user.getPassword()));
        User savedUser = userRepository.save(user);

        // Add role-specific record
        if (savedUser.getRole() == Role.STUDENT) {
            Student student = new Student();
            student.setUser(savedUser);
            student.setSchool(school);
            student.setLevel(level);
            studentRepository.save(student);
        } else if (savedUser.getRole() == Role.TEACHER) {
            Teacher teacher = new Teacher();
            teacher.setUser(savedUser);
            teacher.setSchool(school);
            teacher.setSpecialization(specialization);
            teacherRepository.save(teacher);
        }

        return savedUser;
    }

}
