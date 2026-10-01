package com.farmer.add_region_page.FarmPage;

import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;


@Data
@AllArgsConstructor
@NoArgsConstructor
public class FarmDTO {

    private Long id;

    @NotNull(message="Please,Enter FarmName!")
    private  String name;

    private Double area;

    private Long regionId;


}
