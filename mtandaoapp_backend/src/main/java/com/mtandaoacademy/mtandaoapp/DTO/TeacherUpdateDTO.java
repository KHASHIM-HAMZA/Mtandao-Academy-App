package com.mtandaoacademy.mtandaoapp.DTO;


import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.Size;

public class TeacherUpdateDTO {

    @Email(message = "Email should be valid")
    private String email;

    @Size(max = 15, message = "Phone number must not exceed 15 characters")
    private String phoneNumber;

    @Size(max = 100, message = "School name must not exceed 100 characters")
    private String school;

    @Size(max = 100, message = "Qualification must not exceed 100 characters")
    private String qualification;

    @Size(max = 50, message = "Experience must not exceed 50 characters")
    private String experience;

    // Constructors
    public TeacherUpdateDTO() {}

    public TeacherUpdateDTO(String email, String phoneNumber, String school,
                            String qualification, String experience) {
        this.email = email;
        this.phoneNumber = phoneNumber;
        this.school = school;
        this.qualification = qualification;
        this.experience = experience;
    }

    // Getters and Setters
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
}