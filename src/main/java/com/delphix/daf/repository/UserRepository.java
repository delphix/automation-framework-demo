package com.delphix.daf.repository;

import java.util.Optional;
import com.delphix.daf.model.User;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByUsername(String username);
}
