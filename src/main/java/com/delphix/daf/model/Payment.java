package com.delphix.daf.model;

import lombok.*;
import javax.persistence.*;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;
import com.fasterxml.jackson.annotation.JsonIdentityReference;
import com.fasterxml.jackson.annotation.JsonIdentityInfo;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.ObjectIdGenerators;

@Entity
@Getter @Setter
@NoArgsConstructor
@Table(name = "payments")
public class Payment extends AuditModel {
    @Id @GeneratedValue
    private Long id;

    @JsonProperty("patient_id")
    @JsonIdentityInfo(generator = ObjectIdGenerators.PropertyGenerator.class, property = "id")
    @JsonIdentityReference(alwaysAsId = true)
    @ManyToOne
    @OnDelete(action = OnDeleteAction.CASCADE)
    @JoinColumn(name = "patient_id")
    private Patient patient;

    private @NonNull Integer amount;
    private @NonNull String authcode;
    private @NonNull String currency;
    private @NonNull Boolean captured;
    private @NonNull String type;
}
