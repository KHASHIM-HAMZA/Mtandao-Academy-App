package com.mtandaoacademy.mtandaoapp.Service;

import com.mtandaoacademy.mtandaoapp.Model.Resource;
import com.mtandaoacademy.mtandaoapp.Repository.ResourceRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class ResourceService {

    @Autowired
    private ResourceRepository resourceRepository;

    public Resource uploadResource(Resource resource) {
        resource.setUploadedAt(LocalDateTime.now());
        return resourceRepository.save(resource);
    }

    public List<Resource> getAllResources() {
        return resourceRepository.findAll();
    }

    public List<Resource> filterByType(String type) {
        return resourceRepository.findByType(type);
    }

    public List<Resource> filterBySubject(String subject) {
        return resourceRepository.findBySubject(subject);
    }

    public List<Resource> filterByLevel(String level) {
        return resourceRepository.findByEducationLevel(level);
    }

    public List<Resource> filterByCreator(String creator) {
        return resourceRepository.findByCreatorContainingIgnoreCase(creator);
    }

    public void deleteResource(Long id) {
        resourceRepository.deleteById(id);
    }
}
