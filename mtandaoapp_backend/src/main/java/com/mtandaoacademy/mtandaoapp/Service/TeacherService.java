package com.mtandaoacademy.mtandaoapp.Service;


import com.mtandaoacademy.mtandaoapp.Model.Teacher;
import com.mtandaoacademy.mtandaoapp.Repository.UserRepo.TeacherRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
public class TeacherService {
    @Autowired
    TeacherRepository teacherRepository;
    public Optional<Teacher> getTeacherById(Long id) {
        return  teacherRepository.findTeacherById(id);
    }
}
