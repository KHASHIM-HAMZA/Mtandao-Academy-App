package com.mtandaoacademy.mtandaoapp.Controller.OnlineTest;

import com.mtandaoacademy.mtandaoapp.Model.OnlineTest.Question;
import com.mtandaoacademy.mtandaoapp.Service.OnlineTest.QuestionService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/questions")
public class QuestionController {

    private final QuestionService service;

    public QuestionController(QuestionService service) {
        this.service = service;
    }

    @PreAuthorize("hasAnyRole('TEACHER', 'ADMIN')")
    @PostMapping("/add")
    public ResponseEntity<Question> addQuestion(@RequestBody Question question) {
        return ResponseEntity.ok(service.addQuestion(question));
    }

    @GetMapping("/test/{testId}")
    public ResponseEntity<List<Question>> getQuestionsByTest(@PathVariable Long testId) {
        return ResponseEntity.ok(service.getQuestionsByTest(testId));
    }

    @PreAuthorize("hasAnyRole('TEACHER', 'ADMIN')")
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteQuestion(@PathVariable Long id) {
        service.deleteQuestion(id);
        return ResponseEntity.noContent().build();
    }
}
