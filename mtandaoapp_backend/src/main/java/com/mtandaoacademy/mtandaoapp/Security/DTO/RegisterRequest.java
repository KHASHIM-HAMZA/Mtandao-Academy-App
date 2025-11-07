package com.mtandaoacademy.mtandaoapp.Security.DTO;


import com.mtandaoacademy.mtandaoapp.Model.Enums.Role;

public class RegisterRequest {
    private String name;
    private String email;
    private String password;
    private Role role; // STUDENT / TEACHER / ADMIN

    // Student-specific fields (optional)
    private String school;
    private String level; // primary/olevel/alevel

    // Teacher fields (optional)
    private String specialization;

    // getters/setters


    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public Role getRole() {
        return role;
    }

    public void setRole(Role role) {
        this.role = role;
    }

    public String getSchool() {
        return school;
    }

    public void setSchool(String school) {
        this.school = school;
    }

    public String getLevel() {
        return level;
    }

    public void setLevel(String level) {
        this.level = level;
    }

    public String getSpecialization() {
        return specialization;
    }

    public void setSpecialization(String specialization) {
        this.specialization = specialization;
    }
}
