package com.farmer.service;

import com.farmer.repository.*;
import org.springframework.stereotype.Service;
import com.farmer.dto.CropCycleDTO;
import com.farmer.mapper.*;
import com.farmer.entity.*;

@Service
public class CropCycleService {
    private CropCycleRepository cropcycleRepository;
    private FarmRepository farmRepository;
    
    public CropCycleService(CropCycleRepository cropcycleRepository,FarmRepository farmRepository){
        this.cropcycleRepository=cropcycleRepository;
        this.farmRepository=farmRepository; 
    }

    //POST
    public CropCycleDTO addCrop(CropCycleDTO dto){
        Farm farm=farmRepository.findById(dto.getFarmId()).orElseThrow(()-> new RuntimeException("farm not faund!"));
        CropCycle cropcycle=CropCycleMapper.toENTITY(dto,farm);
        return CropCycleMapper.toDTO(cropcycleRepository.save(cropcycle));
    }



}
