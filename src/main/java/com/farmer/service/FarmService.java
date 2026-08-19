package com.farmer.service;

import com.farmer.BackendApplication;
import com.farmer.dto.*;
import com.farmer.mapper.FarmMapper;
import com.farmer.repository.*;
import com.farmer.entity.*;

import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class FarmService {
    private final BackendApplication backendApplication;
    private final FarmRepository farmRepository;
    private final RegionRepository regionRepository;

    public FarmService(FarmRepository farmRepository,RegionRepository regionRepository, BackendApplication backendApplication){
        this.farmRepository=farmRepository;
        this.regionRepository=regionRepository;
        this.backendApplication = backendApplication;
    }

    //POST FARM
    public FarmDTO addFarm(FarmDTO dto) {

        Region region = regionRepository.findById(dto.getRegionId()).orElseThrow(() -> new RuntimeException("Region not found"));

        Farm farm = FarmMapper.toENTITY(dto, region);
        return FarmMapper.toDTO(farmRepository.save(farm));
    }
    //GET FARM
    public FarmDTO getFarmById(Long id){
        Farm farm=farmRepository.findById(id).orElseThrow(()-> new RuntimeException("farm not found!"));
        return FarmMapper.toDTO(farm);

    }

    //GET ALL FARM
    public List<FarmDTO> getAllFarm(){
        return farmRepository.findAll().stream().map(FarmMapper::toDTO).toList();
    }
}
