package com.farmer.controller;

import com.farmer.entity.Village;
import com.farmer.service.VillageService;

import java.util.List;

import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/village")
@CrossOrigin
public class VillageController {

    private final VillageService villageService;

    public VillageController(VillageService villageService) {
        this.villageService = villageService;
    }

    @PostMapping
    public Village addVillage(@RequestBody Village village) {
        return villageService.addVillage(village);
    }

    @GetMapping
    public List<Village> getAllVillage() {
        return villageService.getAllVillage();
    }

    @GetMapping("/{id}")
    public Village getVillageById(@PathVariable Long id) {
        return villageService.getVillageById(id);
    }

    @DeleteMapping("/{id}")
    public String deleteVillage(@PathVariable Long id) {
        villageService.deleteVillage(id);
        return "Village deleted successfully";
    }
}