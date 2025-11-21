package com.mtandaoacademy.mtandaoapp.Security.DTO;


import com.mtandaoacademy.mtandaoapp.Model.Enums.Role;
import jakarta.persistence.ElementCollection;

import java.util.List;

public class RegisterRequest {
    private String name;
    private String email;
    private String phoneNumber;
    private String password;
    private Role role; // STUDENT / TEACHER / ADMIN

    // Student-specific fields (optional)
    private String school;
    private String level; // primary/olevel/alevel
    private String sub_level;

    // Teacher fields (optional)
    private String qualification; // e.g. MSc. Mathematics Education

    private String experience; // e.g. "8 years"

    @ElementCollection
    private List<String> subjects; // e.g. ["Mathematics", "Physics"]


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

    public String getPhoneNumber() {
        return phoneNumber;
    }

    public void setPhoneNumber(String phoneNumber) {
        this.phoneNumber = phoneNumber;
    }

    public String getSub_level() {
        return sub_level;
    }

    public void setSub_level(String sub_level) {
        this.sub_level = sub_level;
    }

    public String getQualification() {
        return qualification;
    }

    public void setQualification(String qualification) {
        this.qualification = qualification;
    }

    public String getExperience() {
        return experience;
    }

    public void setExperience(String experience) {
        this.experience = experience;
    }

    public List<String> getSubjects() {
        return subjects;
    }

    public void setSubjects(List<String> subjects) {
        this.subjects = subjects;
    }
}
