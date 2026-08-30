package com.farmer.add_region_page;

import org.springframework.web.bind.annotation.*;

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

    @DeleteMapping("/{id}")
    public String datetefarm(@PathVariable Long id){
        farmService.deletefarm(id);
        return ("delete farm complete");
    }
}
