package com.mtandaoacademy.mtandaoapp.Controller;


import com.mtandaoacademy.mtandaoapp.DTO.UserDTO;
import com.mtandaoacademy.mtandaoapp.Model.Enums.Role;
import com.mtandaoacademy.mtandaoapp.Model.User;
import com.mtandaoacademy.mtandaoapp.Repository.UserRepository;
import com.mtandaoacademy.mtandaoapp.Service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/users")
@CrossOrigin(origins = "*")
public class UserController {

    @Autowired
    UserRepository userRepository;

    @Autowired
    private UserService userService;


    @GetMapping("/all")
    public ResponseEntity<List<UserDTO>> getAllUsers() {

        return userService.getAllUser();
    }


    // ---------------- REGISTER ----------------
    @PostMapping("/register")
    public User register(@RequestBody Map<String, Object> body) {
        User user = new User();
        user.setName((String) body.get("name"));
        user.setEmail((String) body.get("email"));
        user.setPassword((String) body.get("password"));
        user.setRole(Enum.valueOf(
                com.mtandaoacademy.mtandaoapp.Model.Enums.Role.class,
                ((String) body.get("role")).toUpperCase()
        ));

        String school = (String) body.get("school");
        String level = (String) body.get("level");
        String specialization = (String) body.get("specialization");
        String department = (String) body.get("department");
        String regNo = (String) body.get("registrationNumber");

        return userService.registerUser(user, school, level, specialization, department, regNo);
    }

    // ---------------- LOGIN ----------------
    @PostMapping("/login")
    public User login(@RequestBody Map<String, String> body) {
        return userService.loginUser(body.get("email"), body.get("password"));
    }

    // ---------------- GOOGLE LOGIN ----------------
    @PostMapping("/google-login")
    public User googleLogin(@RequestBody Map<String, String> body) {
        String googleId = body.get("googleId");
        String email = body.get("email");
        String name = body.get("name");
        String profilePhoto = body.get("profilePhoto");
        return userService.loginWithGoogle(googleId, email, name, profilePhoto);
    }
}
