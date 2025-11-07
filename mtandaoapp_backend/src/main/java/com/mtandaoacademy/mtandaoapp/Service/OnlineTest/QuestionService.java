package com.mtandaoacademy.mtandaoapp.Service.OnlineTest;


import com.mtandaoacademy.mtandaoapp.Model.OnlineTest.Question;
import com.mtandaoacademy.mtandaoapp.Repository.OnlineTest.QuestionRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class QuestionService {
    private final QuestionRepository repo;

    public QuestionService(QuestionRepository repo) {
        this.repo = repo;
    }

    public Question addQuestion(Question question) {
        return repo.save(question);
    }

    public List<Question> getQuestionsByTest(Long testId) {
        return repo.findByTestId(testId);
    }

    public void deleteQuestion(Long id) {
        repo.deleteById(id);
    }
}
