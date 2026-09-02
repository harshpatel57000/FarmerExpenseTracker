package com.farmer.Agro_expense;

import java.time.LocalDate;

import jakarta.validation.constraints.NotNull;
import lombok.*;

@Builder
@NoArgsConstructor
@AllArgsConstructor
@Data
public class AgroDTO {
    

    private Long id;
    
    @NotNull(message="!Please,Enter Name")
    private String productName;

    @NotNull(message="!Please,Enter Quantity")
    private ValueUnitDTO quantity;
    
    @NotNull(message="!Plese,Enter Measurement")
    private ValueUnitDTO measurement;

    @NotNull(message="!Please,Enter PricePerUnit")
    private Float pricePerUnit;

    private ValueUnitDTO totalWeight;

    private Float totalAmount;

    @NotNull(message="!Please,Enter Date")
    private LocalDate purchaseDate;
}