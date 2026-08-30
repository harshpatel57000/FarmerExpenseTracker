package com.farmer.add_region_page;

import com.farmer.add_region_page.Village;
import com.farmer.add_region_page.VillageDTO;


public  class VillageMapper {

    //entity to DTO
    public static VillageDTO toDTO(Village village){
        return new VillageDTO(village.getId(),village.getName(),village.getPinCode());
    }

    //dto to entity
    public static Village toEntity(VillageDTO dto){
        return new Village(dto.getName(),dto.getPinCode());
    }
}
