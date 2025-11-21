package com.mtandaoacademy.mtandaoapp.Model;

import com.fasterxml.jackson.annotation.JsonBackReference;
import jakarta.persistence.*;

import java.time.LocalDateTime;
import java.util.List;

@Entity
@Table(name = "teachers")
public class Teacher {

    @Id
    private Long id; // same as user id

    @OneToOne
    @MapsId
    @JoinColumn(name = "id")
    @JsonBackReference(value = "user-teacher")
    private User user;

    private String school;

    private String specialization; // main subject or area

    private String qualification; // e.g. MSc. Mathematics Education

    private String experience; // e.g. "8 years"

    @ElementCollection
    private List<String> subjects; // e.g. ["Mathematics", "Physics"]

    private LocalDateTime joinDate = LocalDateTime.now(); // defaults to now

    // Getters & Setters
    public Long getId() { return id; }

    public void setId(Long id) { this.id = id; }

    public User getUser() { return user; }

    public void setUser(User user) { this.user = user; }

    public String getSchool() { return school; }

    public void setSchool(String school) { this.school = school; }

    public String getSpecialization() { return specialization; }

    public void setSpecialization(String specialization) { this.specialization = specialization; }

    public String getQualification() { return qualification; }

    public void setQualification(String qualification) { this.qualification = qualification; }

    public String getExperience() { return experience; }

    public void setExperience(String experience) { this.experience = experience; }

    public List<String> getSubjects() { return subjects; }

    public void setSubjects(List<String> subjects) { this.subjects = subjects; }

    public LocalDateTime getJoinDate() {
        return joinDate;
    }

    public void setJoinDate(LocalDateTime joinDate) {
        this.joinDate = joinDate;
    }
}
