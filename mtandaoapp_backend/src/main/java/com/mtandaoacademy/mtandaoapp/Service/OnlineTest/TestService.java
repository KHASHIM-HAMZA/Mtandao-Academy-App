package com.mtandaoacademy.mtandaoapp.Service.OnlineTest;



import com.mtandaoacademy.mtandaoapp.Model.OnlineTest.Test;
import com.mtandaoacademy.mtandaoapp.Repository.OnlineTest.TestRepository;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public class TestService {
    private final TestRepository repo;

    public TestService(TestRepository repo) {
        this.repo = repo;
    }

    public Test createTest(Test test) {
        return repo.save(test);
    }

    public List<Test> getAllTests() {
        return repo.findAll();
    }

    public List<Test> getPublishedTests() {
        return repo.findByPublishedTrue();
    }

    public Optional<Test> getTestById(Long id) {
        return repo.findById(id);
    }

    public void deleteTest(Long id) {
        repo.deleteById(id);
    }

    public Test publishTest(Long id) {
        Test test = repo.findById(id).orElseThrow(() -> new RuntimeException("Test not found"));
        test.setPublished(true);
        return repo.save(test);
    }
}
