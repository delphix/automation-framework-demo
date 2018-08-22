package com.delphix.daf.repository;

import java.util.List;
import com.delphix.daf.model.User;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserRepository extends JpaRepository<User, Long> {

    List<User> findByUsername(String username);
}
