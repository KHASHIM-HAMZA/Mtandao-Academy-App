package com.mtandaoacademy.mtandaoapp.Repository;

import com.mtandaoacademy.mtandaoapp.Model.Resource;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ResourceRepository extends JpaRepository<Resource, Long> {
    List<Resource> findByType(String type);
    List<Resource> findBySubject(String subject);
    List<Resource> findByEducationLevel(String educationLevel);
    List<Resource> findByCreatorContainingIgnoreCase(String creator);
}
