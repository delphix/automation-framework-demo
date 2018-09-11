package com.delphix.daf.model;

import lombok.*;
import javax.persistence.*;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;
import com.fasterxml.jackson.annotation.JsonIgnore;

@Entity
@Getter @Setter
@NoArgsConstructor
@Table(name = "billings")
public class Billing extends AuditModel {
    @Id @GeneratedValue
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "patient_id", nullable = false)
    @OnDelete(action = OnDeleteAction.CASCADE)
    @JsonIgnore
    private Patient patient;

    private @NonNull String ccnum;
    private @NonNull String cctype;
    private @NonNull Integer ccexpmonth;
    private @NonNull Integer ccexpyear;
    private @NonNull String address1;
    private @NonNull String address2;
    private @NonNull String city;
    private @NonNull String state;
    private @NonNull String zip;

}
