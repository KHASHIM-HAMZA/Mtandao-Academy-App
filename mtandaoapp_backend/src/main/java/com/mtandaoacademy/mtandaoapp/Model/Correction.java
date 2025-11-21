package com.mtandaoacademy.mtandaoapp.Model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "corrections")
public class Correction {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String title;
    private String subject;
    private String educationLevel;
    private String sublevel;
    private int year;

    // File-based solution (PDF)
    private String fileName;
    private String fileUrl;

    // Video-based solution (YouTube)
    private String videoTitle;
    private String youtubeUrl;
    private String videoThumbnail;

    // Type to distinguish between PDF and Video corrections
    @Enumerated(EnumType.STRING)
    private CorrectionType type = CorrectionType.PDF;

    private String uploadedBy;
    private LocalDateTime uploadedAt = LocalDateTime.now();

    @ManyToOne
    @JoinColumn(name = "past_paper_id")
    private PastPaper pastPaper;

    public enum CorrectionType {
        PDF,        // Traditional PDF solutions
        VIDEO,      // YouTube video explanations
        HYBRID      // Both PDF and Video (future enhancement)
    }

    // Getters & Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getSubject() { return subject; }
    public void setSubject(String subject) { this.subject = subject; }

    public String getEducationLevel() { return educationLevel; }
    public void setEducationLevel(String educationLevel) { this.educationLevel = educationLevel; }

    public String getSublevel() { return sublevel; }
    public void setSublevel(String sublevel) { this.sublevel = sublevel; }

    public int getYear() { return year; }
    public void setYear(int year) { this.year = year; }

    public String getFileName() { return fileName; }
    public void setFileName(String fileName) { this.fileName = fileName; }

    public String getFileUrl() { return fileUrl; }
    public void setFileUrl(String fileUrl) { this.fileUrl = fileUrl; }

    public String getVideoTitle() { return videoTitle; }
    public void setVideoTitle(String videoTitle) { this.videoTitle = videoTitle; }

    public String getYoutubeUrl() { return youtubeUrl; }
    public void setYoutubeUrl(String youtubeUrl) { this.youtubeUrl = youtubeUrl; }

    public String getVideoThumbnail() { return videoThumbnail; }
    public void setVideoThumbnail(String videoThumbnail) { this.videoThumbnail = videoThumbnail; }

    public CorrectionType getType() { return type; }
    public void setType(CorrectionType type) { this.type = type; }

    public String getUploadedBy() { return uploadedBy; }
    public void setUploadedBy(String uploadedBy) { this.uploadedBy = uploadedBy; }

    public LocalDateTime getUploadedAt() { return uploadedAt; }
    public void setUploadedAt(LocalDateTime uploadedAt) { this.uploadedAt = uploadedAt; }

    public PastPaper getPastPaper() { return pastPaper; }
    public void setPastPaper(PastPaper pastPaper) { this.pastPaper = pastPaper; }
}