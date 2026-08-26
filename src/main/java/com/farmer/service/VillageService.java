package com.farmer.service;

import com.farmer.entity.Village;
import com.farmer.mapper.VillageMapper;
import com.farmer.repository.VillageRepository;
import com.farmer.dto.VillageDTO;

import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class VillageService {

    private final VillageRepository villageRepository;

    public VillageService(VillageRepository villageRepository) {
        this.villageRepository = villageRepository;
    }

    //POST
    public VillageDTO addVillage(Village village){
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
                .orElseThrow(() -> new RuntimeException("Village not found")));
    }

    //delete
    public void deleteVillage(Long id) {
        villageRepository.deleteById(id);
    }

    //put 
    public VillageDTO updateVillageName(Long id,VillageDTO villageDTO){
        Village village=villageRepository.findById(id).orElseThrow(() -> new RuntimeException("village not found id :"+id));
        village.setName(villageDTO.getName());
        village.setPinCode(villageDTO.getPinCode());
        Village updateVillage=villageRepository.save(village);
        return VillageMapper.toDTO(updateVillage);
    }
}