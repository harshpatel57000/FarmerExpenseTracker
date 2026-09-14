package com.farmer.add_region_page.VillagePage;

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
        User user=userRepository.findById(villagedto.getUserId()).orElseThrow(()-> new ErrorException("User Not Found!"));

        Village village=VillageMapper.toEntity(villagedto,user);
        Village VillageEntity= villageRepository.save(village);
        return VillageMapper.toDTO(VillageEntity);
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