package com.farmer.add_region_page.RegionPage;

import lombok.NoArgsConstructor;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Data;
import com.farmer.Login_page.User;
@Data
@NoArgsConstructor
@AllArgsConstructor
public class RegionDTO {

    
    private Long id;

    @NotNull(message="Please,Enter Region Name!")
    private String name;

    
    //private Long villageId; 

    private Long userId;

}
