package com.farmer.Agro_expense;

import com.farmer.Agro_expense.enumValue.AgroUnit;

import lombok.*;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ValueUnitDTO {

    private Double value;

    private AgroUnit unit;
}