package com.farmer.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import com.farmer.entity.Farm;


@Data
@AllArgsConstructor
@NoArgsConstructor
public class FarmDTO {

    private Long id;

    private  String name;

    private Double area;

    private Long regionId;


}
