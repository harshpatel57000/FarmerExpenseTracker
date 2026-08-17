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


    public VillageDTO addVillage(Village village){
        Village VillageEntity= villageRepository.save(village);
        return VillageMapper.toDTO(VillageEntity);
    }

    public List<VillageDTO> getAllVillage() {

        return villageRepository.findAll().stream().map(VillageMapper::toDTO).toList();
    };
    

    public VillageDTO getVillageById(Long id) {
        return VillageMapper.toDTO(villageRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Village not found")));
    }

    public void deleteVillage(Long id) {
        villageRepository.deleteById(id);
    }
}