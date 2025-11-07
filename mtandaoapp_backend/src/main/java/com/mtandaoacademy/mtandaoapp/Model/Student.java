package com.mtandaoacademy.mtandaoapp.Model;

import com.fasterxml.jackson.annotation.JsonBackReference;
import jakarta.persistence.*;

@Entity
@Table(name = "students")
public class Student {

    @Id
    private Long id; // same as user id

    @OneToOne
    @MapsId
    @JoinColumn(name = "id")
    @JsonBackReference(value = "user-student")
    private User user;


    private String school;

    private String level; // e.g., primary, olevel, alevel


    // Getters & Setters
    public Long getId() { return id; }

    public void setId(Long id) { this.id = id; }

    public User getUser() { return user; }

    public void setUser(User user) { this.user = user; }

    public String getSchool() { return school; }

    public void setSchool(String school) { this.school = school; }

    public String getLevel() { return level; }

    public void setLevel(String level) { this.level = level; }
}
