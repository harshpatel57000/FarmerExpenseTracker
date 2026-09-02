package com.farmer.Agro_expense.enumValue;

import jakarta.persistence.*;
import lombok.*;

@Embeddable
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ValueUnit {

    private Double value;

    @Enumerated(EnumType.STRING)
    private AgroUnit unit;
}