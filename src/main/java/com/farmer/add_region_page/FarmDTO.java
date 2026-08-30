package com.farmer.add_region_page;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;


@Data
@AllArgsConstructor
@NoArgsConstructor
public class FarmDTO {

    private Long id;

    private  String name;

    private Double area;

    private Long regionId;


}
