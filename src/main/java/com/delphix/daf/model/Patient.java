package com.delphix.daf.model;

import lombok.*;
import javax.persistence.*;

@Entity
@Getter @Setter
@NoArgsConstructor
@Table(name = "patients")
public class Patient extends AuditModel {
    @Id @GeneratedValue
    private Long id;
    private @NonNull String firstname;
    private @NonNull String middlename;
    private @NonNull String lastname;
    private @NonNull String ssn;
    private @NonNull String dob;
    private @NonNull String address1;
    private @NonNull String address2;
    private @NonNull String city;
    private @NonNull String state;
    private @NonNull String zip;
}
