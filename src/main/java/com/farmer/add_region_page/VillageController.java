package com.farmer.add_region_page;

import com.farmer.add_region_page.VillageMapper;
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
    public ResponseEntity<Map<String,String>> getVillageById(@PathVariable Long id) {
        Map<String,String> massage=new HashMap<>();
        VillageDTO villageDTO=villageService.getVillageById(id);
        String name=villageDTO.getName();
        massage.put("Village name ",name);
        return ResponseEntity.ok(massage);
    }

    @DeleteMapping("/{id}")
    public String deleteVillage(@PathVariable Long id) {
        villageService.deleteVillage(id);
        return "Village deleted successfully";
    }

    @PutMapping("/{id}")
    public ResponseEntity<String> upadeVillageName(@PathVariable Long id ,@RequestBody VillageDTO villageDTO){
        villageService.updateVillageName(id,villageDTO);
        return ResponseEntity.ok("village name updated");
    }
}