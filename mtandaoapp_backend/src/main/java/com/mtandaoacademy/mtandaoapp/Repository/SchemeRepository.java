package com.mtandaoacademy.mtandaoapp.Repository;

import com.mtandaoacademy.mtandaoapp.Model.SchemeOfWork;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface SchemeRepository extends JpaRepository<SchemeOfWork, Long> {

    @Query("SELECT s FROM SchemeOfWork s WHERE s.uploadedBy = :uploadedBy")
    List<SchemeOfWork> findByUploadedBy(@Param("uploadedBy") String uploadedBy);

    List<SchemeOfWork> findByVisibility(SchemeOfWork.Visibility visibility);
}