package com.delphix.daf.controller;

import org.springframework.http.HttpStatus;
import com.auth0.jwt.JWT;
import com.auth0.jwt.algorithms.Algorithm;
import java.util.Optional;
import java.util.Calendar;
import com.delphix.daf.exception.UnauthorizedException;
import com.delphix.daf.model.User;
import com.delphix.daf.repository.UserRepository;
import org.springframework.core.env.Environment;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import javax.validation.Valid;

@RestController
public class AuthController {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private BCryptPasswordEncoder bCryptPasswordEncoder;

    @Autowired
    private Environment env;

    public AuthController(
        UserRepository userRepository,
        BCryptPasswordEncoder bCryptPasswordEncoder
    ) {
        this.userRepository = userRepository;
        this.bCryptPasswordEncoder = bCryptPasswordEncoder;
    }

    private User getUserdata(User user) {
        return userRepository.findByUsername(user.getUsername()).map(userData -> {
            return userData;
        }).orElseThrow(() -> new UnauthorizedException("Invalid Credentials"));
    }

    private String createToken(String user) {
        Calendar calendar = Calendar.getInstance();
        calendar.add(Calendar.DAY_OF_YEAR, 1);

        Algorithm algorithm = Algorithm.HMAC256(env.getProperty("jwt.secret"));
        String token = JWT.create()
            .withIssuer("delphix")
            .withExpiresAt(calendar.getTime())
            .withClaim("user", user)
            .sign(algorithm);

        return token;
    }

    @PostMapping("/auth/sign-up")
    public User signUp(@RequestBody User user) {
        user.setPassword(bCryptPasswordEncoder.encode(user.getPassword()));
        return userRepository.save(user);
    }

    @PostMapping("/auth/login")
    public ResponseEntity<String> login(@RequestBody User user) {
        User userData = this.getUserdata(user);
        if (!bCryptPasswordEncoder.matches(user.getPassword(), userData.getPassword())) {
            throw new UnauthorizedException("Invalid Credentials");

        }
        return new ResponseEntity<>(this.createToken(userData.getUsername()), HttpStatus.OK);
    }
}
