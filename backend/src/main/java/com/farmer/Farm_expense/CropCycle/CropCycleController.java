package com.farmer.Farm_expense.CropCycle;

import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;

import org.springframework.http.ResponseEntity;

import java.util.Map;


@RestController
@RequestMapping("/api/cropcycle")
public class CropCycleController{
    private final CropCycleService cropcycleService;
    public CropCycleController(CropCycleService cropcycleService){
        this.cropcycleService=cropcycleService;
    }

    @PostMapping
    public ResponseEntity<CropCycleDTO> addCrop(@Valid @RequestBody CropCycleDTO dto){
        return ResponseEntity.ok(cropcycleService.addCrop(dto));
    } 
    @PutMapping("/{id}/complete")
    public CropCycle completecrop(@Valid @PathVariable Long id,@RequestBody Map<String,String> request){
        String endDate =request.get("endDate");
        return cropcycleService.completeCrop(id,endDate);
    }
}
