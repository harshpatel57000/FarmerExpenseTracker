package com.farmer.controller;

import com.farmer.service.FarmService;
import org.springframework.web.bind.annotation.*;
import com.farmer.dto.FarmDTO;
import java.util.List;
@RestController
@RequestMapping("/api/farm")
@CrossOrigin
public class FarmController {
    private final FarmService farmService;

    public FarmController(FarmService farmService){
        this.farmService=farmService;
    }
    @PostMapping
    public FarmDTO addFarm(@RequestBody FarmDTO farmdto){
        return farmService.addFarm(farmdto);
    }

    @GetMapping
    public List<FarmDTO> getAllFarm(){
        return farmService.getAllFarm();
    }

    @GetMapping("/{id}")
    public FarmDTO getFarmById(@PathVariable Long id){
        return farmService.getFarmById(id);
    }
}
