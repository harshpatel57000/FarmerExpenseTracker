package com.farmer.mapper;

import com.farmer.entity.Village;
import com.farmer.dto.VillageDTO;


public class VillageMapper {

    //entity to DTO
    public static VillageDTO toDTO(Village village){
        return new VillageDTO(village.getId(),village.getName());
    }

    //dto to entity
    public static Village toEntity(VillageDTO dto){
        return new Village(dto.getName());
    }
}
