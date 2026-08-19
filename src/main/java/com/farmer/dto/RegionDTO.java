package com.farmer.dto;

import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import lombok.Data;
@Data
@NoArgsConstructor
@AllArgsConstructor
public class RegionDTO {

    
    private Long id;

    private String name;

    private Long villageId;

}
