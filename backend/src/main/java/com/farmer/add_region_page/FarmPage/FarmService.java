package com.farmer.add_region_page.FarmPage;
import com.farmer.Login_page.User;
import com.farmer.Login_page.UserRepository;
import com.farmer.add_region_page.RegionPage.Region;
import com.farmer.add_region_page.RegionPage.RegionRepository;
import com.farmer.exception.ErrorException;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class FarmService {
    
    private final FarmRepository farmRepository;
    private final RegionRepository regionRepository;
    private final UserRepository userRepository;

    public FarmService(FarmRepository farmRepository,RegionRepository regionRepository,UserRepository userRepository){
        this.farmRepository=farmRepository;
        this.regionRepository=regionRepository;
        this.userRepository=userRepository;
    }

    private User getLoggedInUser(){

        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();

        if(authentication == null || !authentication.isAuthenticated() || authentication.getName() == null || authentication.getName().equals("anymouseuser")) throw new ErrorException("User Is Not Authenticated");

        String email =authentication.getName();

        return userRepository.findByEmailId(email).orElseThrow(() -> new ErrorException("Logged-in User Not Found"));
    }

    //POST FARM
    public FarmDTO addFarm(FarmDTO dto) {

        User user =getLoggedInUser();

        Region region = regionRepository.findById(dto.getRegionId()).orElseThrow(() -> new ErrorException("Region not found"));

        Farm farm = FarmMapper.toENTITY(dto, region,user);
        return FarmMapper.toDTO(farmRepository.save(farm));
    }
    //GET FARM BY Id
    public FarmDTO getFarmById(Long id){

        User user =getLoggedInUser();

        Farm farm=farmRepository.findByIdAndUserId(id,user.getId()).orElseThrow(()-> new ErrorException("farm not found!"));
        return FarmMapper.toDTO(farm);

    }

    //GET ALL FARM
    public List<FarmDTO> getAllFarm(){

        User user =getLoggedInUser();

        return farmRepository.findAllByUserId(user.getId()).stream().map(FarmMapper::toDTO).toList();
    }

    //delete farm
    public void deletefarm(Long id){
        User user =getLoggedInUser();

        Farm farm = farmRepository.findByIdAndUserId(id,user.getId()).orElseThrow(() -> new ErrorException("Farm Not Found"));

        farmRepository.deleteById(id);
    }
}
