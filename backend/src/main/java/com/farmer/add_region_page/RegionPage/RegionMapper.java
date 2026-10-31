package com.farmer.add_region_page.RegionPage;

import com.farmer.Login_page.User;
//import com.farmer.add_region_page.VillagePage.Village;
public class RegionMapper {
 //entity to dto
 public static RegionDTO toDTO(Region region){
    return new RegionDTO(region.getId(),region.getName(),region.getUser().getId());
 }
//dto to entity
 public static Region toENTITY(RegionDTO dto,User user){
   Region region=new Region();

   region.setId(dto.getId());
   region.setName(dto.getName());
   region.setUser(user);
   return region;
 }
}
