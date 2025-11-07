package com.mtandaoacademy.mtandaoapp.Model.OnlineTest;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "tests")
public class Test {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String title;
    private String subject;
    private String level;
    private int duration; // in minutes
    private String creator; // teacher email or name
    private boolean published = false;
    private LocalDateTime createdAt = LocalDateTime.now();

    @OneToMany(mappedBy = "test", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.LAZY)
    private List<Question> questions = new ArrayList<>();

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getSubject() { return subject; }
    public void setSubject(String subject) { this.subject = subject; }

    public String getLevel() { return level; }
    public void setLevel(String level) { this.level = level; }

    public int getDuration() { return duration; }
    public void setDuration(int duration) { this.duration = duration; }

    public String getCreator() { return creator; }
    public void setCreator(String creator) { this.creator = creator; }

    public boolean isPublished() { return published; }
    public void setPublished(boolean published) { this.published = published; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public List<Question> getQuestions() { return questions; }
    public void setQuestions(List<Question> questions) {
        this.questions.clear();
        if (questions != null) {
            questions.forEach(q -> q.setTest(this));
            this.questions.addAll(questions);
        }
    }
}
