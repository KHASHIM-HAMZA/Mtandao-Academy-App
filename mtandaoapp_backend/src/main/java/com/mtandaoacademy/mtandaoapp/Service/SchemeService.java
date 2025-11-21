package com.mtandaoacademy.mtandaoapp.Service;

import com.mtandaoacademy.mtandaoapp.Model.SchemeOfWork;
import com.mtandaoacademy.mtandaoapp.Repository.SchemeRepository;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.List;
import java.util.UUID;

@Service
public class SchemeService {

    private final SchemeRepository schemeRepository;

    @Value("${file.upload-dir:uploads/schemes/}")
    private String UPLOAD_DIR;

    public SchemeService(SchemeRepository schemeRepository) {
        this.schemeRepository = schemeRepository;
    }

    public SchemeOfWork uploadScheme(MultipartFile file, SchemeOfWork scheme) throws IOException {
        // Create upload directory if it doesn't exist
        Path uploadPath = Paths.get(UPLOAD_DIR);
        if (!Files.exists(uploadPath)) {
            Files.createDirectories(uploadPath);
        }

        // Generate unique filename
        String originalFileName = file.getOriginalFilename();
        String fileExtension = "";
        if (originalFileName != null && originalFileName.contains(".")) {
            fileExtension = originalFileName.substring(originalFileName.lastIndexOf("."));
        }

        String uniqueName = UUID.randomUUID().toString() + fileExtension;
        Path filePath = uploadPath.resolve(uniqueName);

        // Copy file to upload directory
        Files.copy(file.getInputStream(), filePath, StandardCopyOption.REPLACE_EXISTING);

        // Set file details
        scheme.setFileName(originalFileName);
        scheme.setFileUrl("/files/schemes/" + uniqueName);

        System.out.println("💾 Saving scheme with uploadedBy: " + scheme.getUploadedBy());

        return schemeRepository.save(scheme);
    }

    public List<SchemeOfWork> getAllSchemes() {
        return schemeRepository.findAll();
    }

    public List<SchemeOfWork> getPublicSchemes() {
        return schemeRepository.findByVisibility(SchemeOfWork.Visibility.PUBLIC);
    }

    public List<SchemeOfWork> getTeacherSchemes(String teacherEmail) {
        return schemeRepository.findByUploadedBy(teacherEmail);
    }

    public void deleteScheme(Long id) {
        schemeRepository.deleteById(id);
    }
}