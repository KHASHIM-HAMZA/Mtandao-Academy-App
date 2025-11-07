package com.mtandaoacademy.mtandaoapp.Repository.UserRepo;

import com.mtandaoacademy.mtandaoapp.Model.Student;
import com.mtandaoacademy.mtandaoapp.Model.Teacher;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface TeacherRepository extends JpaRepository<Teacher, Long> {
    Optional<Teacher> findByUserEmail(String email);

    Optional<Teacher> findTeacherById(Long id);
}