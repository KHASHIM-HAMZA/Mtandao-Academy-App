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
        u.setPassword(passwordEncoder.encode(req.getPassword()));
        u.setRole(req.getRole());
        u = userRepository.save(u);

        // create student or teacher profile depending on role
        if (req.getRole() == Role.STUDENT) {
            Student s = new Student();
            s.setUser(u);
            s.setSchool(req.getSchool());
            s.setLevel(req.getLevel());
            studentRepository.save(s);
        } else if (req.getRole() == Role.TEACHER) {
            Teacher t = new Teacher();
            t.setUser(u);
            t.setSchool(req.getSchool());
            t.setSpecialization(req.getSpecialization());
            teacherRepository.save(t);
        }

        String token = jwtUtil.generateToken(u.getEmail(), u.getRole().name(), u.getId());
        return new AuthResponse(token, u.getRole().name(), u.getId(), u.getEmail(), u.getName());
    }

    public AuthResponse login(AuthRequest request) {
        // authenticate with username/password so Spring maintains auth context (optional)
        authenticationManager.authenticate(new UsernamePasswordAuthenticationToken(request.getEmail(), request.getPassword()));

        User u = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new RuntimeException("User not found"));

        String token = jwtUtil.generateToken(u.getEmail(), u.getRole().name(), u.getId());
        return new AuthResponse(token, u.getRole().name(), u.getId(), u.getEmail(), u.getName());
    }
}
