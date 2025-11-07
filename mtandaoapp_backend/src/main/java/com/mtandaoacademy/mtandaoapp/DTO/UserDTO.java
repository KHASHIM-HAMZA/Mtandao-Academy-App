package com.mtandaoacademy.mtandaoapp.DTO;

import com.mtandaoacademy.mtandaoapp.Model.Enums.Role;
import com.mtandaoacademy.mtandaoapp.Model.Student;
import com.mtandaoacademy.mtandaoapp.Model.Teacher;

public class UserDTO {
    private Long id;
    private String name;
    private String email;
    private Role role;
    private Object profile; // will hold either Student or Teacher data

    public UserDTO(Long id, String name, String email, Role role, Object profile) {
        this.id = id;
        this.name = name;
        this.email = email;
        this.role = role;
        this.profile = profile;
    }

    // Getters only (optional setters)
    public Long getId() { return id; }
    public String getName() { return name; }
    public String getEmail() { return email; }
    public Role getRole() { return role; }
    public Object getProfile() { return profile; }
}
