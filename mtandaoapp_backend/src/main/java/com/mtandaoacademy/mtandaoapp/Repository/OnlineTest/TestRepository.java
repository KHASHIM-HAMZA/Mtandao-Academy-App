package com.mtandaoacademy.mtandaoapp.Repository.OnlineTest;

import com.mtandaoacademy.mtandaoapp.Model.OnlineTest.Test;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface TestRepository extends JpaRepository<Test, Long> {
    List<Test> findByPublishedTrue();
    List<Test> findByCreator(String creator);
}
