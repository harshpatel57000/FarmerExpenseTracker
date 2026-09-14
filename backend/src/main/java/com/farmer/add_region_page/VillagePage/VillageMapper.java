package com.farmer.add_region_page.VillagePage;

import com.farmer.Login_page.User;

public  class VillageMapper {

    //entity to DTO
    public static VillageDTO toDTO(Village village){
        return new VillageDTO(village.getId(),village.getUserId(),village.getName(),village.getPinCode());
    }

    //dto to entity
    public static Village toEntity(VillageDTO dto,User user){
        return new Village(user,dto.getName(),dto.getPinCode());
    }
}
