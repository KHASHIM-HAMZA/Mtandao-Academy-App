package com.mtandaoacademy.mtandaoapp.Repository;

import com.mtandaoacademy.mtandaoapp.Model.Correction;
import com.mtandaoacademy.mtandaoapp.Model.PastPaper;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface CorrectionRepository extends JpaRepository<Correction, Long> {
    List<Correction> findByPastPaperId(Long pastPaperId);
    List<Correction> findByPastPaperIdAndType(Long pastPaperId, Correction.CorrectionType type);

    List<PastPaper> findByUploadedBy(String uploadedBy);
}