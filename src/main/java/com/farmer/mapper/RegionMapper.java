package com.farmer.mapper;

import com.farmer.dto.RegionDTO;
import com.farmer.entity.Region;
import com.farmer.entity.Village;
public class RegionMapper {
 //entity to dto
 public static RegionDTO toDTO(Region region){
    return new RegionDTO(region.getId(),region.getName(),region.getVillage().getId());
 }
//dto to entity
 public static Region toENTITY(RegionDTO dto,Village village){
   Region region=new Region();

   region.setId(dto.getId());
   region.setName(dto.getName());
   region.setVillage(village);
   return region;
 }
}
