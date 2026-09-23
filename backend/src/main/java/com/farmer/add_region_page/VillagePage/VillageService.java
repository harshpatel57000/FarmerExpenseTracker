package com.farmer.add_region_page.VillagePage;

import org.springframework.http.ResponseEntity;
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
    public String addVillage(VillageDTO villagedto){

        String emailId=SecurityContextHolder.getContext().getAuthentication().getName();
        User user=userRepository.findByEmailId(emailId).orElseThrow(()-> new ErrorException("User Not Found!"));

        Village village=villageRepository.findByNameAndPinCode(villagedto.getName(),villagedto.getPinCode()).orElseGet(() ->{

        Village newVillage=VillageMapper.toEntity(villagedto);

        return villageRepository.save(newVillage);
        });
        
        //village available in user's villages
        if(user.getVillages().contains(village)){
            return "Village AllReaddy Available";
        }
        user.getVillages().add(village);

        village.getUsers().add(user);

        userRepository.save(user);
       
        return "Village is Added";
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