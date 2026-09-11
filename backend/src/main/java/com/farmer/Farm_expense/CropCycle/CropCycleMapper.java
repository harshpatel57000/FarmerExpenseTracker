package com.farmer.Farm_expense.CropCycle;

import com.farmer.Farm_expense.CropCycle.*;
import com.farmer.add_region_page.FarmPage.Farm;





public class CropCycleMapper {
    
    //entity to dto
    public static CropCycleDTO toDTO(CropCycle cropcycle){
        return  CropCycleDTO.builder()
        .id(cropcycle.getId())
        .farmId(cropcycle.getFarm().getId())
        .cropName(cropcycle.getCropName())
        .startDate(cropcycle.getStartDate())
        .endDate(cropcycle.getEndDate())
        .status(cropcycle.getStatus())
        .build();
    }

    //dto to entity
        public static CropCycle toENTITY(
            CropCycleDTO dto,
            Farm farm) {

        return CropCycle.builder()
                .id(dto.getId())
                .farm(farm)
                .cropName(dto.getCropName())
                .startDate(dto.getStartDate())
                .endDate(dto.getEndDate())
                .status(dto.getStatus())
                .build();
    }


}
