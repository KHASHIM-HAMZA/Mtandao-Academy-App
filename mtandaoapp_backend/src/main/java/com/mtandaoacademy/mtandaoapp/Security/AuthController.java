package com.mtandaoacademy.mtandaoapp.Security;



import com.mtandaoacademy.mtandaoapp.Model.Enums.Role;
import com.mtandaoacademy.mtandaoapp.Model.User;
import com.mtandaoacademy.mtandaoapp.Repository.UserRepository;
import com.mtandaoacademy.mtandaoapp.Security.DTO.AuthRequest;
import com.mtandaoacademy.mtandaoapp.Security.DTO.AuthResponse;
import com.mtandaoacademy.mtandaoapp.Security.DTO.RegisterRequest;
import com.mtandaoacademy.mtandaoapp.Service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/auth")
public class AuthController extends GoogleAuthService{

    private final AuthService authService;
    private final UserRepository userRepository;
    private final JwtUtil jwtUtil;
    private final GoogleAuthService googleAuthService;
    public AuthController(AuthService authService, UserRepository userRepository, JwtUtil jwtUtil, GoogleAuthService googleAuthService) { this.authService = authService;
        this.userRepository = userRepository;
        this.jwtUtil = jwtUtil;
        this.googleAuthService = googleAuthService;
    }

    @PostMapping("/register")
    public ResponseEntity<AuthResponse> register(@RequestBody RegisterRequest req) {
        AuthResponse resp = authService.register(req);
        return ResponseEntity.status(201).body(resp);
    }

    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(@RequestBody AuthRequest req) {
        AuthResponse resp = authService.login(req);
        return ResponseEntity.ok(resp);
    }

    // optional: /me to return current user (requires auth)
    @GetMapping("/me")
    public ResponseEntity<?> me(@org.springframework.security.core.annotation.AuthenticationPrincipal org.springframework.security.core.userdetails.UserDetails userDetails) {
        return ResponseEntity.ok(userDetails);
    }

    @PostMapping("/google-login")
    public ResponseEntity<?> googleLogin(@RequestBody Map<String, String> request) {
        try {
            String idToken = request.get("idToken");

            // 1. Verify token
            var payload = googleAuthService.verifyToken(idToken);

            String email = payload.getEmail();
            String name = (String) payload.get("name");

            // 2. Check if user exists
            Optional<User> existingUser = userRepository.findByEmail(email);
            User user;

            if (existingUser.isPresent()) {
                user = existingUser.get();
            } else {
                // 3. Create new user
                user = new User();
                user.setEmail(email);
                user.setName(name);
                user.setRole(Role.STUDENT); // or TEACHER if via teacher sign-in
                userRepository.save(user);
            }

            // 4. Generate your own JWT for this user
            String token = jwtUtil.generateToken(
                    user.getEmail(),               // username (email)
                    user.getRole().name(),         // role as string (e.g., "STUDENT")
                    user.getId()
            );

            return ResponseEntity.ok(Map.of(
                    "token", token,
                    "email", user.getEmail(),
                    "role", user.getRole()
            ));

        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("error", e.getMessage()));
        }
    }

}

