package com.farmer.Farm_expense.CropCycle;


import lombok.*;

import java.time.LocalDate;

import jakarta.validation.constraints.NotNull;


@Getter
@Setter
@Builder
@Data
@AllArgsConstructor
@NoArgsConstructor
public class CropCycleDTO {
    

    private Long id;

    @NotNull(message="Please,Enter FarmId")
    private Long farmId;

    @NotNull(message="Please,Enter CropName")
    private String cropName;

    @NotNull(message="Please,Enter startDate")
    private LocalDate startDate;

    private LocalDate endDate;

    
    private String status;
}
