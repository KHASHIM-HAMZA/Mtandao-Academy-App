package com.mtandaoacademy.mtandaoapp.Controller;

import com.mtandaoacademy.mtandaoapp.Model.PastPaper;
import com.mtandaoacademy.mtandaoapp.Model.Correction;
import com.mtandaoacademy.mtandaoapp.Service.PastPaperService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import java.io.IOException;
import java.util.List;

@RestController
@RequestMapping("/api/pastpapers")
@CrossOrigin(origins = "*")
public class PastPaperController {

    private final PastPaperService service;

    public PastPaperController(PastPaperService service) {
        this.service = service;
    }

    // Upload past paper
    @PostMapping("/upload")
    public ResponseEntity<PastPaper> uploadPastPaper(
            @RequestParam("file") MultipartFile file,
            @RequestParam("title") String title,
            @RequestParam("subject") String subject,
            @RequestParam("educationLevel") String educationLevel,
            @RequestParam("sublevel") String sublevel,
            @RequestParam("year") int year,
            @RequestParam("uploadedBy") String uploadedBy
    ) throws IOException {
        PastPaper paper = new PastPaper();
        paper.setTitle(title);
        paper.setSubject(subject);
        paper.setEducationLevel(educationLevel);
        paper.setSublevel(sublevel);
        paper.setYear(year);
        paper.setUploadedBy(uploadedBy);
        return ResponseEntity.ok(service.uploadPastPaper(file, paper));
    }

    // Upload correction - for both PDF and Video
    @PostMapping("/uploadCorrection")
    public ResponseEntity<Correction> uploadCorrection(
            @RequestParam(value = "file", required = false) MultipartFile file,
            @RequestParam("title") String title,
            @RequestParam("subject") String subject,
            @RequestParam("educationLevel") String educationLevel,
            @RequestParam("sublevel") String sublevel,
            @RequestParam("year") int year,
            @RequestParam("uploadedBy") String uploadedBy,
            @RequestParam("pastPaperId") Long pastPaperId,
            @RequestParam(value = "youtubeUrl", required = false) String youtubeUrl,
            @RequestParam(value = "videoTitle", required = false) String videoTitle,
            @RequestParam(value = "type", defaultValue = "PDF") String type
    ) throws IOException {
        Correction correction = new Correction();
        correction.setTitle(title);
        correction.setSubject(subject);
        correction.setEducationLevel(educationLevel);
        correction.setSublevel(sublevel);
        correction.setYear(year);
        correction.setUploadedBy(uploadedBy);
        correction.setYoutubeUrl(youtubeUrl);
        correction.setVideoTitle(videoTitle);

        // Set correction type
        if ("VIDEO".equalsIgnoreCase(type)) {
            correction.setType(Correction.CorrectionType.VIDEO);
        } else {
            correction.setType(Correction.CorrectionType.PDF);
        }

        PastPaper paper = new PastPaper();
        paper.setId(pastPaperId);
        correction.setPastPaper(paper);

        return ResponseEntity.ok(service.uploadCorrection(file, correction));
    }

    // Get all past papers
    @GetMapping("/all")
    public ResponseEntity<List<PastPaper>> getAllPapers() {
        return ResponseEntity.ok(service.getAllPastPapers());
    }

    @GetMapping("/creator/{uploadedBy}")
    @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
    public ResponseEntity<List<PastPaper>> getPaperByCreator(@PathVariable String uploadedBy) {
        return ResponseEntity.ok(service.getPaperByCreator(uploadedBy));
    }

    @GetMapping("/corrections/all")
    public ResponseEntity<List<Correction>> getAllCorrections() {
        return ResponseEntity.ok(service.getAllCorrections());
    }

    // Get corrections for specific past paper
    @GetMapping("/{id}/corrections")
    public ResponseEntity<List<Correction>> getCorrections(@PathVariable Long id) {
        return ResponseEntity.ok(service.getCorrectionsForPaper(id));
    }

    // Get corrections by type for specific past paper
    @GetMapping("/{id}/corrections/{type}")
    public ResponseEntity<List<Correction>> getCorrectionsByType(
            @PathVariable Long id,
            @PathVariable String type) {
        Correction.CorrectionType correctionType = Correction.CorrectionType.valueOf(type.toUpperCase());
        return ResponseEntity.ok(service.getCorrectionsByType(id, correctionType));
    }
}