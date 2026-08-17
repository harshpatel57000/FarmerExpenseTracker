package com.farmer.service;

import com.farmer.entity.Village;
import com.farmer.repository.VillageRepository;

import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class VillageService {

    private final VillageRepository villageRepository;

    public VillageService(VillageRepository villageRepository) {
        this.villageRepository = villageRepository;
    }

    public Village addVillage(Village village) {
        return villageRepository.save(village);
    }

    public List<Village> getAllVillage() {
        return villageRepository.findAll();
    }

    public Village getVillageById(Long id) {
        return villageRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Village not found"));
    }

    public void deleteVillage(Long id) {
        villageRepository.deleteById(id);
    }
}