package com.mtandaoacademy.mtandaoapp.Controller;

import com.mtandaoacademy.mtandaoapp.Model.Resource;
import com.mtandaoacademy.mtandaoapp.Service.ResourceService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.*;
import java.util.List;

@RestController
@RequestMapping("/api/resources")
public class ResourceController {

    private static final String UPLOAD_DIR = "uploads/resources/";

    @Autowired
    private ResourceService resourceService;

    // ✅ Upload resource (Teacher or Admin only)
    @PostMapping("/upload")
    @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
    public ResponseEntity<?> uploadResource(
            @RequestParam("file") MultipartFile file,
            @RequestParam("title") String title,
            @RequestParam("description") String description,
            @RequestParam("type") String type,
            @RequestParam("educationLevel") String educationLevel,
            @RequestParam("sublevel") String subLevel,
            @RequestParam("subject") String subject,
            @RequestParam("creator") String creator
    ) throws IOException {

        if (file.isEmpty()) {
            return ResponseEntity.badRequest().body("File is required");
        }

        // Save file
        Path uploadPath = Paths.get(UPLOAD_DIR);
        if (!Files.exists(uploadPath)) {
            Files.createDirectories(uploadPath);
        }

        String fileName = System.currentTimeMillis() + "_" + file.getOriginalFilename();
        Path filePath = uploadPath.resolve(fileName);
        Files.copy(file.getInputStream(), filePath, StandardCopyOption.REPLACE_EXISTING);

        String fileUrl = "/files/resources/" + fileName;  // Optional static resource URL mapping

        Resource resource = new Resource(
                title, description, type, educationLevel,subLevel, subject,
                fileUrl, fileName, (file.getSize() / 1024) + " KB",
                creator, null
        );

        return ResponseEntity.ok(resourceService.uploadResource(resource));
    }

    // ✅ Get all resources
    @GetMapping
    public ResponseEntity<List<Resource>> getAllResources() {
        return ResponseEntity.ok(resourceService.getAllResources());
    }

    // ✅ Filter endpoints
    @GetMapping("/filter/type/{type}")
    public ResponseEntity<List<Resource>> filterByType(@PathVariable String type) {
        return ResponseEntity.ok(resourceService.filterByType(type));
    }

    @GetMapping("/filter/subject/{subject}")
    public ResponseEntity<List<Resource>> filterBySubject(@PathVariable String subject) {
        return ResponseEntity.ok(resourceService.filterBySubject(subject));
    }

    @GetMapping("/filter/level/{level}")
    public ResponseEntity<List<Resource>> filterByLevel(@PathVariable String level) {
        return ResponseEntity.ok(resourceService.filterByLevel(level));
    }

    @GetMapping("/filter/creator/{creator}")
    @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
    public ResponseEntity<List<Resource>> filterByCreator(@PathVariable String creator) {
        return ResponseEntity.ok(resourceService.filterByCreator(creator));
    }

    // ✅ Delete resource (Admin or Teacher who uploaded)
    @DeleteMapping("/{id}")
    @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
    public ResponseEntity<?> deleteResource(@PathVariable Long id) {
        resourceService.deleteResource(id);
        return ResponseEntity.ok("Resource deleted successfully");
    }
}
