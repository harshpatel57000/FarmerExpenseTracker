package com.farmer.add_region_page.VillagePage;

import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import com.farmer.Login_page.User;
import com.farmer.Login_page.UserRepository;
import com.farmer.exception.ErrorException;

import java.util.List;

@Service
public class VillageService {

    private final VillageRepository villageRepository;
    private final UserRepository userRepository;

    public VillageService(VillageRepository villageRepository,UserRepository userRepository) {
        this.villageRepository = villageRepository;
        this.userRepository=userRepository;
    }

    //POST
    public VillageDTO addVillage(VillageDTO villagedto){

        String emailId=SecurityContextHolder.getContext().getAuthentication().getName();
        User user=userRepository.findByEmailId(emailId).orElseThrow(()-> new ErrorException("User Not Found!"));

        Village village=VillageMapper.toEntity(villagedto);
        Village villageEntity= villageRepository.save(village);
       
        user.getVillages().add(villageEntity);
        userRepository.save(user);
       
        return VillageMapper.toDTO(villageEntity);
    }

    //GET ALL
    public List<VillageDTO> getAllVillage() {

        return villageRepository.findAll().stream().map(VillageMapper::toDTO).toList();
    };
    
    //GET BY ID
    public VillageDTO getVillageById(Long id) {
        return VillageMapper.toDTO(villageRepository.findById(id)
                .orElseThrow(() -> new ErrorException("Village not found")));
    }

    //delete
    public void deleteVillage(Long id) {
        villageRepository.deleteById(id);
    }

    //put 
    public VillageDTO updateVillageName(Long id,VillageDTO villageDTO){
        Village village=villageRepository.findById(id).orElseThrow(() -> new ErrorException("village not found id :"+id));
        village.setName(villageDTO.getName());
        village.setPinCode(villageDTO.getPinCode());
        Village updateVillage=villageRepository.save(village);
        return VillageMapper.toDTO(updateVillage);
    }
}