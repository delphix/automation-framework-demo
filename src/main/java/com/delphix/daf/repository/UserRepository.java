package com.delphix.daf.repository;

import java.util.List;
import com.delphix.daf.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

public interface UserRepository extends JpaRepository<User, Long> {

    List<User> findByName(String name);
}
