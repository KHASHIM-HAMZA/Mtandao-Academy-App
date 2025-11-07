package com.mtandaoacademy.mtandaoapp.Model;


import com.fasterxml.jackson.annotation.JsonBackReference;
import jakarta.persistence.*;

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

    private String specialization;


    // Getters & Setters
    public Long getId() { return id; }

    public void setId(Long id) { this.id = id; }

    public User getUser() { return user; }

    public void setUser(User user) { this.user = user; }

    public String getSchool() { return school; }

    public void setSchool(String school) { this.school = school; }

    public String getSpecialization() { return specialization; }

    public void setSpecialization(String specialization) { this.specialization = specialization; }

}
