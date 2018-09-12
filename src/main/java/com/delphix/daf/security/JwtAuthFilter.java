package com.delphix.daf.security;

import com.delphix.daf.exception.UnauthorizedException;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import com.delphix.daf.model.User;
import com.delphix.daf.repository.UserRepository;
import org.springframework.util.StringUtils;
import org.springframework.web.filter.OncePerRequestFilter;
import com.auth0.jwt.exceptions.JWTVerificationException;
import com.auth0.jwt.interfaces.DecodedJWT;
import com.auth0.jwt.JWTVerifier;
import org.springframework.beans.factory.annotation.Autowired;
import com.auth0.jwt.JWT;
import com.auth0.jwt.algorithms.Algorithm;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.core.env.Environment;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;

public class JwtAuthFilter extends OncePerRequestFilter {

    private static final Logger logger = LoggerFactory.getLogger(JwtAuthFilter.class);
    private String userName;

    @Autowired
    private Environment env;

    @Autowired
    private UserRepository userRepository;

    private boolean validateToken(String token) {
        try {
            Algorithm algorithm = Algorithm.HMAC256(env.getProperty("jwt.secret"));
            JWTVerifier verifier = JWT.require(algorithm)
                .withIssuer("delphix")
                .build(); //Reusable verifier instance
            DecodedJWT jwt = verifier.verify(token);
            this.userName = jwt.getClaim("user").asString();
            return true;
        } catch (JWTVerificationException exception){
             logger.error(exception.getMessage());
        }
        return false;
    }

    private String getJwtFromRequest(HttpServletRequest request) {
        String bearerToken = request.getHeader(env.getProperty("jwt.header"));
        if (StringUtils.hasText(bearerToken) && bearerToken.startsWith(env.getProperty("jwt.prefix"))) {
            return bearerToken.substring(7, bearerToken.length());
        }
        return null;
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain) throws ServletException, IOException {
        try {
            String jwt = getJwtFromRequest(request);
            if (StringUtils.hasText(jwt) && this.validateToken(jwt)) {
                User user = userRepository.findByUsername(this.userName).map(userData -> {
                    return userData;
                }).orElseThrow(() -> new UnauthorizedException("Invalid Credentials"));
                UsernamePasswordAuthenticationToken authentication = new UsernamePasswordAuthenticationToken(user, null, new ArrayList<>());
                authentication.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
                SecurityContextHolder.getContext().setAuthentication(authentication);
            }
        } catch (Exception ex) {
            logger.error("Could not set user authentication in security context", ex);
        }

        filterChain.doFilter(request, response);
    }

}
