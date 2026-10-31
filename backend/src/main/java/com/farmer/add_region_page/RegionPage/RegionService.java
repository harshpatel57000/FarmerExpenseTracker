package com.farmer.add_region_page.RegionPage;

import com.farmer.Login_page.User;
import com.farmer.Login_page.UserRepository;
import com.farmer.exception.ErrorException;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class RegionService {
    private final RegionRepository regionRepository;
    private final UserRepository userRepository;

    public RegionService(RegionRepository regionRepository,UserRepository userRepository){
        this.regionRepository=regionRepository;
        this.userRepository=userRepository;
    }   
    
    public User userLoggedIn(){
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
         
        if(authentication == null || !authentication.isAuthenticated() || authentication.getName() == null || authentication.getName().equals("anonymousUser")){
            throw new ErrorException("User Is Not authenticated");
        } 

        String email = authentication.getName();

        return userRepository.findByEmailId(email).orElseThrow(() -> new ErrorException("Logged-in User not Found"));
    }


    //POST
    public RegionDTO addRegion(RegionDTO dto){

        User user = userLoggedIn();
        Region region=RegionMapper.toENTITY(dto,user);
        Region savedRegion=regionRepository.save(region);
        return RegionMapper.toDTO(savedRegion);
    }
    //GET ALL
    public List<RegionDTO> getAllRegion(){
        
        User user = userLoggedIn();

        return regionRepository.findAllByUserId(user.getId()).stream().map(RegionMapper::toDTO).toList();
    }

    //GET BY ID
    public RegionDTO getRegionById(Long id){

        User user = userLoggedIn();

        Region region=  regionRepository.findByIdAndUserId(id,user.getId()).orElseThrow(() ->new ErrorException("region not found!"));
        return RegionMapper.toDTO(region);
    }

    //DELETE
    public void deleteRegion(Long id){

        User user = userLoggedIn();

        Region region = regionRepository.findByIdAndUserId(id, user.getId()).orElseThrow(() ->new ErrorException("Region not found"));

        regionRepository.delete(region);
    }
}
