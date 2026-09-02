package com.farmer.Agro_expense;

import com.farmer.Agro_expense.enumValue.ValueUnit;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;

@Builder
@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "agro_expense")
public class Agro {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(nullable = false)
    private Long id;

    @Column(nullable = false)
    private String productName;

    @Embedded
    @AttributeOverrides({
        @AttributeOverride(
            name = "value",
            column = @Column(name = "quantity_value", nullable = false)
        ),
        @AttributeOverride(
            name = "unit",
            column = @Column(name = "quantity_unit", nullable = false)
        )
    })
    private ValueUnit quantity;

    @Embedded
    @AttributeOverrides({
        @AttributeOverride(
            name = "value",
            column = @Column(name = "measurement_value", nullable = false)
        ),
        @AttributeOverride(
            name = "unit",
            column = @Column(name = "measurement_unit", nullable = false)
        )
    })
    private ValueUnit measurement;

    @Column(nullable = false)
    private Float pricePerUnit;

    @Embedded
    @AttributeOverrides({
        @AttributeOverride(
            name = "value",
            column = @Column(name = "total_value", nullable = false)
        ),
        @AttributeOverride(
            name = "unit",
            column = @Column(name = "total_weight_unit", nullable = false)
        )
    })
    private ValueUnit totalWeight;

    @Column(nullable = false)
    private Float totalAmount;

    @Column(nullable = false)
    private LocalDate purchaseDate;
}