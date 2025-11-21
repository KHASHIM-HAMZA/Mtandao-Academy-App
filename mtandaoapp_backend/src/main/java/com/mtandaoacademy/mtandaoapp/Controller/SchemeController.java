package com.mtandaoacademy.mtandaoapp.Controller;

import com.mtandaoacademy.mtandaoapp.Model.SchemeOfWork;
import com.mtandaoacademy.mtandaoapp.Service.SchemeService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import java.io.IOException;
import java.util.List;

@RestController
@RequestMapping("/api/schemes")
@CrossOrigin(origins = "*")
public class SchemeController {

    private final SchemeService service;

    public SchemeController(SchemeService service) {
        this.service = service;
    }

    @PostMapping("/upload")
    @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
    public ResponseEntity<SchemeOfWork> uploadScheme(
            @RequestParam("file") MultipartFile file,
            @RequestParam("title") String title,
            @RequestParam("subject") String subject,
            @RequestParam("educationLevel") String educationLevel,
            @RequestParam("term") String term,
            @RequestParam("year") int year,
            @RequestParam(value = "week", required = false) Integer week,
            @RequestParam("description") String description,
            @RequestParam("uploadedBy") String uploadedBy,
            @RequestParam("visibility") String visibility
    ) throws IOException {
        SchemeOfWork scheme = new SchemeOfWork();
        scheme.setTitle(title);
        scheme.setSubject(subject);
        scheme.setEducationLevel(educationLevel);
        scheme.setTerm(term);
        scheme.setYear(year);
        scheme.setWeek(week);
        scheme.setDescription(description);

        scheme.setUploadedBy(uploadedBy); // This should be consistent (either always email or always name)

        // Convert String to enum
        try {
            SchemeOfWork.Visibility visibilityEnum = SchemeOfWork.Visibility.valueOf(visibility.toUpperCase());
            scheme.setVisibility(visibilityEnum);
        } catch (IllegalArgumentException e) {
            // Default to PRIVATE if invalid
            scheme.setVisibility(SchemeOfWork.Visibility.PRIVATE);
        }

        return ResponseEntity.ok(service.uploadScheme(file, scheme));
    }


    @GetMapping("/all")
    @PreAuthorize("hasAnyRole('ADMIN')")
    public ResponseEntity<List<SchemeOfWork>> getAll() {
        return ResponseEntity.ok(service.getAllSchemes());
    }

    @GetMapping("/public")
    public ResponseEntity<List<SchemeOfWork>> getPublic() {
        return ResponseEntity.ok(service.getPublicSchemes());
    }

    @GetMapping("/teacher/{email}")
    @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
    public ResponseEntity<List<SchemeOfWork>> getTeacherSchemes(@PathVariable String email) {
        return ResponseEntity.ok(service.getTeacherSchemes(email));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        service.deleteScheme(id);
        return ResponseEntity.noContent().build();
    }
}