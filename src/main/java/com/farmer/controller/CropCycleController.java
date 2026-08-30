package com.farmer.controller;

import org.springframework.web.bind.annotation.*;

import org.springframework.http.ResponseEntity;

import java.util.Map;


import com.farmer.dto.CropCycleDTO;
import com.farmer.entity.CropCycle;
import com.farmer.service.*;

@RestController
@RequestMapping("/api/cropcycle")
public class CropCycleController{
    private final CropCycleService cropcycleService;
    public CropCycleController(CropCycleService cropcycleService){
        this.cropcycleService=cropcycleService;
    }

    @PostMapping
    public ResponseEntity<CropCycleDTO> addCrop(@RequestBody CropCycleDTO dto){
        return ResponseEntity.ok(cropcycleService.addCrop(dto));
    } 
    @PutMapping("/{id}/complete")
    public CropCycle completecrop(@PathVariable Long id,@RequestBody Map<String,String> request){
        String endDate =request.get("endDate");
        return cropcycleService.completeCrop(id,endDate);
    }
}
