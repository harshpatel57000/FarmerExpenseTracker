package com.farmer.add_region_page;

import com.farmer.add_region_page.Farm;
import com.farmer.add_region_page.FarmDTO;
import com.farmer.add_region_page.Region;


public class FarmMapper {
    //entity to dto
    public static FarmDTO toDTO(Farm farm){
        return new FarmDTO(farm.getId(),farm.getName(),farm.getArea(),farm.getRegion().getId());
    }

    //dto to entity
    public static Farm toENTITY(FarmDTO dto,Region region){
        Farm farm=new Farm();

        farm.setId(dto.getId());
        farm.setName(dto.getName());
        farm.setArea(dto.getArea());
        farm.setRegion(region);
        return farm;
    }
}
