package com.mtandaoacademy.mtandaoapp.Service;

import com.mtandaoacademy.mtandaoapp.Model.PastPaper;
import com.mtandaoacademy.mtandaoapp.Model.Correction;
import com.mtandaoacademy.mtandaoapp.Repository.PastPaperRepository;
import com.mtandaoacademy.mtandaoapp.Repository.CorrectionRepository;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.*;
import java.util.List;
import java.util.UUID;

@Service
public class PastPaperService {

    private final PastPaperRepository pastPaperRepo;
    private final CorrectionRepository correctionRepo;
    
    
    public List<PastPaper> getPaperByCreator(String uploadedBy) {
        return pastPaperRepo.findByUploadedBy(uploadedBy);
    };

    @Value("${upload.dir.pastpapers:uploads/pastpapers/}")
    private String pastPaperDir;

    @Value("${upload.dir.corrections:uploads/corrections/}")
    private String correctionDir;

    public PastPaperService(PastPaperRepository pastPaperRepo, CorrectionRepository correctionRepo) {
        this.pastPaperRepo = pastPaperRepo;
        this.correctionRepo = correctionRepo;
    }

    // Upload past paper (unchanged)
    public PastPaper uploadPastPaper(MultipartFile file, PastPaper paper) throws IOException {
        Path dirPath = Paths.get(pastPaperDir);
        if (!Files.exists(dirPath)) Files.createDirectories(dirPath);

        String fileName = System.currentTimeMillis() + "_" + file.getOriginalFilename();
        Path path = dirPath.resolve(fileName);
        Files.copy(file.getInputStream(), path, StandardCopyOption.REPLACE_EXISTING);

        paper.setFileName(fileName);
        paper.setFileUrl("/files/pastpapers/" + fileName);

        return pastPaperRepo.save(paper);
    }

    // Upload correction - UPDATED for both PDF and Video
    public Correction uploadCorrection(MultipartFile file, Correction correction) throws IOException {
        Path dirPath = Paths.get(correctionDir);

        // Handle PDF upload
        if (file != null && !file.isEmpty()) {
            if (!Files.exists(dirPath)) Files.createDirectories(dirPath);

            String fileName = System.currentTimeMillis() + "_" + file.getOriginalFilename();
            Path path = dirPath.resolve(fileName);
            Files.copy(file.getInputStream(), path, StandardCopyOption.REPLACE_EXISTING);

            correction.setFileName(fileName);
            correction.setFileUrl("/files/corrections/" + fileName);
            correction.setType(Correction.CorrectionType.PDF);
        }

        // Handle YouTube video (no file upload needed, just URL)
        if (correction.getYoutubeUrl() != null && !correction.getYoutubeUrl().isEmpty()) {
            correction.setType(Correction.CorrectionType.VIDEO);
            // Extract video ID for thumbnail
            String videoId = extractYouTubeId(correction.getYoutubeUrl());
            if (videoId != null) {
                correction.setVideoThumbnail("https://img.youtube.com/vi/" + videoId + "/0.jpg");
            }
        }

        return correctionRepo.save(correction);
    }

    // Helper method to extract YouTube video ID
    private String extractYouTubeId(String youtubeUrl) {
        String videoId = null;
        if (youtubeUrl != null) {
            String pattern = "(?<=watch\\?v=|/videos/|embed\\/|youtu.be\\/|\\/v\\/|\\/e\\/|watch\\?v%3D|watch\\?feature=player_embedded&v=|%2Fvideos%2F|embed%\u200C\u200B2F|youtu.be%2F|\\/v%2F)[^#\\&\\?\\n]*";
            java.util.regex.Pattern compiledPattern = java.util.regex.Pattern.compile(pattern);
            java.util.regex.Matcher matcher = compiledPattern.matcher(youtubeUrl);
            if (matcher.find()) {
                videoId = matcher.group();
            }
        }
        return videoId;
    }

    public List<PastPaper> getAllPastPapers() {
        return pastPaperRepo.findAll();
    }

    public List<Correction> getCorrectionsForPaper(Long paperId) {
        return correctionRepo.findByPastPaperId(paperId);
    }

    // New method to get corrections by type
    public List<Correction> getCorrectionsByType(Long paperId, Correction.CorrectionType type) {
        return correctionRepo.findByPastPaperIdAndType(paperId, type);
    }

    public List<Correction> getAllCorrections() {
        return correctionRepo.findAll();
    }
}