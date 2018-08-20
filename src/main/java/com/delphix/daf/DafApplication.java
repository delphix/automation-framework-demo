package com.delphix.daf;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

import org.springframework.data.jpa.repository.config.EnableJpaAuditing;

@SpringBootApplication
@EnableJpaAuditing
public class DafApplication {

	public static void main(String[] args) {
		SpringApplication.run(DafApplication.class, args);
	}
}
