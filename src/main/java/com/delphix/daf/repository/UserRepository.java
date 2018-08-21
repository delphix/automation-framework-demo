package com.delphix.daf.repository;

import java.util.List;
import com.delphix.daf.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.web.bind.annotation.CrossOrigin;

@CrossOrigin(origins = "http://localhost:4200")
public interface UserRepository extends JpaRepository<User, Long> {

    List<User> findByUsername(String username);
}
