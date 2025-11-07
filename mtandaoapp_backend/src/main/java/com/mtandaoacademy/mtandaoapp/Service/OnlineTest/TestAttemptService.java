package com.mtandaoacademy.mtandaoapp.Service.OnlineTest;

import com.mtandaoacademy.mtandaoapp.Model.OnlineTest.TestAttempt;
import com.mtandaoacademy.mtandaoapp.Repository.OnlineTest.TestAttemptRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class TestAttemptService {
    private final TestAttemptRepository repo;

    public TestAttemptService(TestAttemptRepository repo) {
        this.repo = repo;
    }

    public TestAttempt saveAttempt(TestAttempt attempt) {
        return repo.save(attempt);
    }

    public List<TestAttempt> getAttemptsByStudent(Long studentId) {
        return repo.findByStudentId(studentId);
    }

    public List<TestAttempt> getAttemptsByTest(Long testId) {
        return repo.findByTestId(testId);
    }

    public List<TestAttempt> getAllAttempts() {
        return repo.findAll();
    }
}
