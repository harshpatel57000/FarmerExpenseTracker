package com.farmer.dto;

import com.farmer.entity.CropCycle;

import lombok.*;

import java.time.LocalDate;


@Getter
@Setter
@Builder
@Data
@AllArgsConstructor
@NoArgsConstructor
public class CropCycleDTO {

    private Long id;

    private Long farmId;

    private String cropName;

    private LocalDate startDate;

    private LocalDate endDate;

    private String status;
}
