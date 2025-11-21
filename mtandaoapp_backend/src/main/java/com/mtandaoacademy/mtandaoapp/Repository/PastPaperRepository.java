package com.mtandaoacademy.mtandaoapp.Repository;

import com.mtandaoacademy.mtandaoapp.Model.PastPaper;
import com.mtandaoacademy.mtandaoapp.Model.Correction;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface PastPaperRepository extends JpaRepository<PastPaper, Long> {
    List<PastPaper> findByEducationLevel(String educationLevel);
    List<PastPaper> findBySubject(String subject);
    List<PastPaper> findByUploadedBy(String uploadedBy);


}


