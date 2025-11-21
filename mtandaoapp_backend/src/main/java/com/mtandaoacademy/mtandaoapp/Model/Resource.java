package com.mtandaoacademy.mtandaoapp.Model;


import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "resources")
public class Resource {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String title;
    private String description;
    private String type;             // e.g., "notes", "books", "pastpapers"
    private String educationLevel;   // e.g., "Form 1", "Form 2", "University"
    private String subLevel;
    private String subject;          // e.g., "Math", "Physics"
    private String fileUrl;          // path to uploaded file
    private String fileName;
    private String fileSize;
    private String creator;          // teacher/admin email or name
    private LocalDateTime uploadedAt;

    public Resource() {}

    public Resource(String title, String description, String type, String educationLevel,String subLevel, String subject,
                    String fileUrl, String fileName, String fileSize, String creator, LocalDateTime uploadedAt) {
        this.title = title;
        this.description = description;
        this.type = type;
        this.educationLevel = educationLevel;
        this.subLevel = subLevel;
        this.subject = subject;
        this.fileUrl = fileUrl;
        this.fileName = fileName;
        this.fileSize = fileSize;
        this.creator = creator;
        this.uploadedAt = uploadedAt;
    }

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public String getEducationLevel() { return educationLevel; }
    public void setEducationLevel(String educationLevel) { this.educationLevel = educationLevel; }

    public String getSubject() { return subject; }
    public void setSubject(String subject) { this.subject = subject; }

    public String getFileUrl() { return fileUrl; }
    public void setFileUrl(String fileUrl) { this.fileUrl = fileUrl; }

    public String getFileName() { return fileName; }
    public void setFileName(String fileName) { this.fileName = fileName; }

    public String getFileSize() { return fileSize; }
    public void setFileSize(String fileSize) { this.fileSize = fileSize; }

    public String getCreator() { return creator; }
    public void setCreator(String creator) { this.creator = creator; }

    public String getSubLevel() {
        return subLevel;
    }

    public void setSubLevel(String subLevel) {
        this.subLevel = subLevel;
    }

    public LocalDateTime getUploadedAt() { return uploadedAt; }
    public void setUploadedAt(LocalDateTime uploadedAt) { this.uploadedAt = uploadedAt; }
}
