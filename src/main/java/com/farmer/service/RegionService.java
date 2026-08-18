package com.farmer.service;

import com.farmer.entity.*;
import com.farmer.repository.*;
import com.farmer.dto.RegionDTO;
 import com.farmer.mapper.RegionMapper;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class RegionService {
    private final RegionRepository regionRepository;
    private final VillageRepository villageRepository;

    public RegionService(RegionRepository regionRepository,VillageRepository villageRepository){
        this.regionRepository=regionRepository;
        this.villageRepository=villageRepository;
    }   
    //POST
    public RegionDTO addRegion(RegionDTO dto){
        Village village=villageRepository.findById(dto.getVillageId()).orElseThrow(() -> new RuntimeException("village not found"));
        Region region=RegionMapper.toENTITY(dto,village);
        Region savedRegion=regionRepository.save(region);
        return RegionMapper.toDTO(savedRegion);
    }
    //GET ALL
    public List<RegionDTO> getAllRegion(){
        return regionRepository.findAll().stream().map(RegionMapper::toDTO).toList();
    }

    //GET BY ID
    public RegionDTO getRegionById(Long id){
      Region region=  regionRepository.findById(id).orElseThrow(() ->new RuntimeException("region not found!"));
        return RegionMapper.toDTO(region);
    }

    //DELETE
    public void deleteRegion(Long id){
        regionRepository.deleteById(id);
    }
}
