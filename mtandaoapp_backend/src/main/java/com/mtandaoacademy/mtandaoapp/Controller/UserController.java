package com.mtandaoacademy.mtandaoapp.Controller;


import com.mtandaoacademy.mtandaoapp.DTO.UserDTO;
import com.mtandaoacademy.mtandaoapp.Model.Enums.Role;
import com.mtandaoacademy.mtandaoapp.Model.User;
import com.mtandaoacademy.mtandaoapp.Repository.UserRepository;
import com.mtandaoacademy.mtandaoapp.Service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
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
    @PreAuthorize("hasAnyRole('ADNIN')")
    public ResponseEntity<List<UserDTO>> getAllUsers() {

        return userService.getAllUser();
    }

}
