package com.farmer.Agro_expense;

import java.time.LocalDate;

import lombok.*;

@Builder
@NoArgsConstructor
@AllArgsConstructor
@Data
public class AgroDTO {

    private Long id;

    private String productName;

    private ValueUnitDTO quantity;

    private ValueUnitDTO measurement;

    private Float pricePerUnit;

    private ValueUnitDTO totalWeight;

    private Float totalAmount;

    private LocalDate purchaseDate;
}