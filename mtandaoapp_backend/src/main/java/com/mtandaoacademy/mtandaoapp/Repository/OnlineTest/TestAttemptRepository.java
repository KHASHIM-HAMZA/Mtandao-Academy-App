package com.mtandaoacademy.mtandaoapp.Repository.OnlineTest;


import com.mtandaoacademy.mtandaoapp.Model.OnlineTest.TestAttempt;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface TestAttemptRepository extends JpaRepository<TestAttempt, Long> {
    List<TestAttempt> findByStudentId(Long studentId);
    List<TestAttempt> findByTestId(Long testId);
}
