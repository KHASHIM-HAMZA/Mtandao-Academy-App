package com.mtandaoacademy.mtandaoapp.Controller.OnlineTest;

import com.mtandaoacademy.mtandaoapp.Model.OnlineTest.TestAttempt;
import com.mtandaoacademy.mtandaoapp.Service.OnlineTest.TestAttemptService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/tests")
public class TestAttemptController {

    private final TestAttemptService service;

    public TestAttemptController(TestAttemptService service) {
        this.service = service;
    }

    @PostMapping("/{testId}/submit")
    public ResponseEntity<TestAttempt> submitResult(
            @PathVariable Long testId,
            @RequestBody TestAttempt attempt) {

        attempt.setTestId(testId);
        return ResponseEntity.ok(service.saveAttempt(attempt));
    }

    @GetMapping("/{testId}/attempts")
    public ResponseEntity<List<TestAttempt>> getTestAttempts(@PathVariable Long testId) {
        return ResponseEntity.ok(service.getAttemptsByTest(testId));
    }

    @GetMapping("/student/{studentId}")
    public ResponseEntity<List<TestAttempt>> getStudentAttempts(@PathVariable Long studentId) {
        return ResponseEntity.ok(service.getAttemptsByStudent(studentId));
    }
}
