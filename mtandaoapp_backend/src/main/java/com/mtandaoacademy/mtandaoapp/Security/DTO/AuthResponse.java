package com.mtandaoacademy.mtandaoapp.Security.DTO;

import java.util.List;

public class AuthResponse {
    private String token;
    private String role;
    private Long userId;
    private String email;
    private String name;
    private String phone;
    private String school;
    private String qualification;
    private String experience;
    private List<String> subjects;
    private String profilePhoto;

    public AuthResponse(String token, String role, Long userId, String email, String name,
                        String phone, String school, String qualification, String experience,
                        List<String> subjects, String profilePhoto) {
        this.token = token;
        this.role = role;
        this.userId = userId;
        this.email = email;
        this.name = name;
        this.phone = phone;
        this.school = school;
        this.qualification = qualification;
        this.experience = experience;
        this.subjects = subjects;
        this.profilePhoto = profilePhoto;
    }

    // Add all getters and setters
    public String getToken() { return token; }
    public void setToken(String token) { this.token = token; }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }

    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public String getSchool() { return school; }
    public void setSchool(String school) { this.school = school; }

    public String getQualification() { return qualification; }
    public void setQualification(String qualification) { this.qualification = qualification; }

    public String getExperience() { return experience; }
    public void setExperience(String experience) { this.experience = experience; }

    public List<String> getSubjects() { return subjects; }
    public void setSubjects(List<String> subjects) { this.subjects = subjects; }

    public String getProfilePhoto() { return profilePhoto; }
    public void setProfilePhoto(String profilePhoto) { this.profilePhoto = profilePhoto; }
}