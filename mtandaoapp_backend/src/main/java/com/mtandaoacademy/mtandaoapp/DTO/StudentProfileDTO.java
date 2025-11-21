package com.mtandaoacademy.mtandaoapp.DTO;


import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public class StudentProfileDTO {
    private Long id;

    @NotBlank(message = "Name is required")
    @Size(min = 2, max = 100, message = "Name must be between 2 and 100 characters")
    private String name;

    @NotBlank(message = "Email is required")
    @Email(message = "Email should be valid")
    private String email;

    @Size(max = 15, message = "Phone number must not exceed 15 characters")
    private String phoneNumber;

    @Size(max = 100, message = "School name must not exceed 100 characters")
    private String school;

    @NotBlank(message = "Education level is required")
    private String level;

    @NotBlank(message = "Grade/Sub-level is required")
    private String sub_level;

    // Constructors
    public StudentProfileDTO() {}

    public StudentProfileDTO(Long id, String name, String email, String phoneNumber,
                             String school, String level, String sub_level) {
        this.id = id;
        this.name = name;
        this.email = email;
        this.phoneNumber = phoneNumber;
        this.school = school;
        this.level = level;
        this.sub_level = sub_level;
    }

    // Getters and Setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

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

    public String getPhoneNumber() {
        return phoneNumber;
    }

    public void setPhoneNumber(String phoneNumber) {
        this.phoneNumber = phoneNumber;
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

    public String getSub_level() {
        return sub_level;
    }

    public void setSub_level(String sub_level) {
        this.sub_level = sub_level;
    }
}