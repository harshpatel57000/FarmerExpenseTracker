package com.farmer.add_region_page.FarmPage;

import com.farmer.Login_page.User;
import com.farmer.add_region_page.RegionPage.Region;


public class FarmMapper {
    //entity to dto
    public static FarmDTO toDTO(Farm farm){
        return new FarmDTO(farm.getId(),farm.getName(),farm.getArea(),farm.getRegion().getId(),farm.getUser().getId());
    }

    //dto to entity
    public static Farm toENTITY(FarmDTO dto,Region region,User user){
        Farm farm=new Farm();

        farm.setId(dto.getId());
        farm.setName(dto.getName());
        farm.setArea(dto.getArea());
        farm.setRegion(region);
        farm.setUser(user);
        return farm;
    }
}
