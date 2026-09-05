package com.farmer.add_region_page.VillagePage;

import org.springframework.stereotype.Service;

import com.farmer.exception.ErrorException;

import java.util.List;

@Service
public class VillageService {

    private final VillageRepository villageRepository;

    public VillageService(VillageRepository villageRepository) {
        this.villageRepository = villageRepository;
    }

    //POST
    public VillageDTO addVillage(VillageDTO villagedto){
        Village village=VillageMapper.toEntity(villagedto);
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