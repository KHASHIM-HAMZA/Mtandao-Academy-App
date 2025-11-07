package com.mtandaoacademy.mtandaoapp.Controller.OnlineTest;


import com.mtandaoacademy.mtandaoapp.Model.OnlineTest.Test;
import com.mtandaoacademy.mtandaoapp.Service.OnlineTest.TestService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/tests")
public class TestController {

    private final TestService service;

    public TestController(TestService service) {
        this.service = service;
    }

    @PreAuthorize("hasAnyRole('TEACHER', 'ADMIN')")
    @PostMapping("/create")
    public ResponseEntity<Test> createTest(@RequestBody Test test) {
        return ResponseEntity.ok(service.createTest(test));
    }

    @PreAuthorize("hasAnyRole('TEACHER', 'ADMIN')")
    @PutMapping("/{id}/publish")
    public ResponseEntity<Test> publishTest(@PathVariable Long id) {
        return ResponseEntity.ok(service.publishTest(id));
    }

    @PreAuthorize("hasRole('STUDENT')")
    @GetMapping("/published")
    public ResponseEntity<List<Test>> getPublishedTests() {
        return ResponseEntity.ok(service.getPublishedTests());
    }

    @GetMapping("/{id}")
    public ResponseEntity<Test> getTestById(@PathVariable Long id) {
        return service.getTestById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PreAuthorize("hasAnyRole('TEACHER', 'ADMIN')")
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteTest(@PathVariable Long id) {
        service.deleteTest(id);
        return ResponseEntity.noContent().build();
    }
}
