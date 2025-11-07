package com.mtandaoacademy.mtandaoapp.Repository;


import com.mtandaoacademy.mtandaoapp.Model.Student;
import com.mtandaoacademy.mtandaoapp.Model.Teacher;
import com.mtandaoacademy.mtandaoapp.Model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByEmail(String email);
    Optional<User> findByGoogleId(String googleId);
    boolean existsByEmail(String email);

}


