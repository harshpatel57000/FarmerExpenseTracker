package com.farmer.controller;

import com.farmer.dto.VillageDTO;
import com.farmer.entity.Village;
import com.farmer.service.VillageService;
import com.farmer.mapper.VillageMapper;
import org.springframework.http.ResponseEntity;
import org.springframework.http.HttpStatus;

import java.util.*;


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
    public ResponseEntity<String> addVillage(@RequestBody VillageDTO villagedto) {
        Village village=VillageMapper.toEntity(villagedto);
             try{
        villageService.addVillage(village);
        return ResponseEntity.ok("VILLAGE IS ADDED");
             }catch(Exception e){
        return ResponseEntity.ok(villagedto.getName()+"  VILLAGE IS ALREADY.EXIST");
             }
    }

    @GetMapping
    public ResponseEntity<Map<String,List<VillageDTO>>> getAllVillage() {
        List<VillageDTO> villageDTO=villageService.getAllVillage();
        HashMap<String,List<VillageDTO>> response=new HashMap<>();
        response.put("LIST OF ALL VILLAGE :",villageDTO);

        return ResponseEntity.ok(response);
    }

    @GetMapping("/{id}")
    public ResponseEntity<VillageDTO> getVillageById(@PathVariable Long id) {
        return ResponseEntity.ok(villageService.getVillageById(id));
    }

    @DeleteMapping("/{id}")
    public String deleteVillage(@PathVariable Long id) {
        villageService.deleteVillage(id);
        return "Village deleted successfully";
    }
}