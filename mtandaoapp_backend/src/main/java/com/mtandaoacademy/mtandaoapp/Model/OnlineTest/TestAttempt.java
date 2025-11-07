package com.mtandaoacademy.mtandaoapp.Model.OnlineTest;


import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "test_attempts")
public class TestAttempt {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Long testId;
    private Long studentId;
    private String studentName;
    private String studentEmail;

    private int score;
    private int totalQuestions;

    private LocalDateTime submittedAt = LocalDateTime.now();

    // Relations (optional if you want to fetch full test details)
    // @ManyToOne
    // private Test test;

    // Getters & Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getTestId() { return testId; }
    public void setTestId(Long testId) { this.testId = testId; }

    public Long getStudentId() { return studentId; }
    public void setStudentId(Long studentId) { this.studentId = studentId; }

    public String getStudentName() { return studentName; }
    public void setStudentName(String studentName) { this.studentName = studentName; }

    public String getStudentEmail() { return studentEmail; }
    public void setStudentEmail(String studentEmail) { this.studentEmail = studentEmail; }

    public int getScore() { return score; }
    public void setScore(int score) { this.score = score; }

    public int getTotalQuestions() { return totalQuestions; }
    public void setTotalQuestions(int totalQuestions) { this.totalQuestions = totalQuestions; }

    public LocalDateTime getSubmittedAt() { return submittedAt; }
    public void setSubmittedAt(LocalDateTime submittedAt) { this.submittedAt = submittedAt; }
}
