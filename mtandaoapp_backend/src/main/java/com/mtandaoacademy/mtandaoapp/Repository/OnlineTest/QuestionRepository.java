package com.mtandaoacademy.mtandaoapp.Repository.OnlineTest;

import com.mtandaoacademy.mtandaoapp.Model.OnlineTest.Question;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface QuestionRepository extends JpaRepository<Question, Long> {
    List<Question> findByTestId(Long testId);
}
