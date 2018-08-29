package com.delphix.daf.model;

import lombok.*;
import javax.persistence.*;

@Entity
@Getter @Setter
@NoArgsConstructor
@Table(name = "users", uniqueConstraints = {
    @UniqueConstraint(columnNames = {
        "username"
    })
})
public class User extends AuditModel {
    @Id @GeneratedValue
    private Long id;
    private @NonNull String username;
    private @NonNull String firstname;
    private @NonNull String lastname;
    private @NonNull String password;
}
