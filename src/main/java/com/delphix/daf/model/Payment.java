package com.delphix.daf.model;

import lombok.*;
import javax.persistence.*;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;
import com.fasterxml.jackson.annotation.JsonIgnore;

@Entity
@Getter @Setter
@NoArgsConstructor
@Table(name = "payments")
public class Payment extends AuditModel {
    @Id @GeneratedValue
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "patient_id", nullable = false)
    @OnDelete(action = OnDeleteAction.CASCADE)
    @JsonIgnore
    private Patient patient;

    private @NonNull Integer amount;
    private @NonNull String authcode;
    private @NonNull String currency;
    private @NonNull Boolean captured;
    private @NonNull String type;
}
