package com.mtandaoacademy.mtandaoapp.Security;


import com.mtandaoacademy.mtandaoapp.Model.*;
import com.mtandaoacademy.mtandaoapp.Model.Enums.Role;
import com.mtandaoacademy.mtandaoapp.Repository.UserRepo.StudentRepository;
import com.mtandaoacademy.mtandaoapp.Repository.UserRepo.TeacherRepository;
import com.mtandaoacademy.mtandaoapp.Repository.UserRepository;
import com.mtandaoacademy.mtandaoapp.Security.DTO.AuthRequest;
import com.mtandaoacademy.mtandaoapp.Security.DTO.AuthResponse;
import com.mtandaoacademy.mtandaoapp.Security.DTO.RegisterRequest;
import org.springframework.security.authentication.*;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class AuthService {

    private final UserRepository userRepository;
    private final StudentRepository studentRepository; // if you have one
    private final TeacherRepository teacherRepository; // if you have one
    private final PasswordEncoder passwordEncoder;
    private final AuthenticationManager authenticationManager;
    private final JwtUtil jwtUtil;

    public AuthService(UserRepository userRepository,
                       StudentRepository studentRepository,
                       TeacherRepository teacherRepository,
                       PasswordEncoder passwordEncoder,
                       AuthenticationManager authenticationManager,
                       JwtUtil jwtUtil) {
        this.userRepository = userRepository;
        this.studentRepository = studentRepository;
        this.teacherRepository = teacherRepository;
        this.passwordEncoder = passwordEncoder;
        this.authenticationManager = authenticationManager;
        this.jwtUtil = jwtUtil;
    }

    public AuthResponse register(RegisterRequest req) {
        if (userRepository.existsByEmail(req.getEmail())) {
            throw new RuntimeException("Email already used");
        }

        User u = new User();
        u.setName(req.getName());
        u.setEmail(req.getEmail());
        u.setPhoneNumber(req.getPhoneNumber());
        u.setPassword(passwordEncoder.encode(req.getPassword()));
        u.setRole(req.getRole());
        u = userRepository.save(u);

        // Initialize variables for the response
        String school = "";
        String qualification = "";
        String experience = "";
        List<String> subjects = List.of();
        String profilePhoto = u.getProfilePhoto();

        // create student or teacher profile depending on role
        if (req.getRole() == Role.STUDENT) {
            Student s = new Student();
            s.setUser(u);
            s.setSchool(req.getSchool());
            s.setLevel(req.getLevel());
            s.setSub_level(req.getSub_level());
            studentRepository.save(s);
            school = req.getSchool() != null ? req.getSchool() : "";
        } else if (req.getRole() == Role.TEACHER) {
            Teacher t = new Teacher();
            t.setUser(u);
            t.setSchool(req.getSchool());
            t.setExperience(req.getExperience());
            t.setQualification(req.getQualification());
            t.setSubjects(req.getSubjects());
            teacherRepository.save(t);

            school = req.getSchool() != null ? req.getSchool() : "";
            qualification = req.getQualification() != null ? req.getQualification() : "";
            experience = req.getExperience() != null ? req.getExperience() : "";
            subjects = req.getSubjects() != null ? req.getSubjects() : List.of();
        }

        String token = jwtUtil.generateToken(u.getEmail(), u.getRole().name(), u.getId());

        return new AuthResponse(
                token,
                u.getRole().name(),
                u.getId(),
                u.getEmail(),
                u.getName(),
                u.getPhoneNumber(),
                school,
                qualification,
                experience,
                subjects,
                profilePhoto
        );
    }
    public AuthResponse login(AuthRequest request) {
        // authenticate with username/password so Spring maintains auth context
        authenticationManager.authenticate(new UsernamePasswordAuthenticationToken(request.getEmail(), request.getPassword()));

        User u = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new RuntimeException("User not found"));

        String token = jwtUtil.generateToken(u.getEmail(), u.getRole().name(), u.getId());

        // Initialize additional data
        String phone = u.getPhoneNumber();
        String school = "";
        String qualification = "";
        String experience = "";
        List<String> subjects = null;
        String profilePhoto = u.getProfilePhoto();

        // Load teacher-specific data if user is a teacher
        if (u.getRole() == Role.TEACHER && u.getTeacher() != null) {
            Teacher teacher = u.getTeacher();
            school = teacher.getSchool() != null ? teacher.getSchool() : "";
            qualification = teacher.getQualification() != null ? teacher.getQualification() : "";
            experience = teacher.getExperience() != null ? teacher.getExperience() : "";
            subjects = teacher.getSubjects() != null ? teacher.getSubjects() : List.of();
        }

        // Load student-specific data if user is a student
        if (u.getRole() == Role.STUDENT && u.getStudent() != null) {
            Student student = u.getStudent();
            school = student.getSchool() != null ? student.getSchool() : "";
        }

        return new AuthResponse(token, u.getRole().name(), u.getId(), u.getEmail(),
                u.getName(), phone, school, qualification, experience,
                subjects, profilePhoto);
    }
}
