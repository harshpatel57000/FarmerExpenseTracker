package com.farmer.add_region_page;

import org.springframework.web.bind.annotation.*;

import java.util.List;


@RestController
@RequestMapping("/api/region")
@CrossOrigin
public class RegionController {
 private final RegionService regionService;

  public RegionController(RegionService regionService){
    this.regionService=regionService;
  }

  @PostMapping
  public RegionDTO addRegion(@RequestBody RegionDTO dto){
    return regionService.addRegion(dto);
  }

  @GetMapping
  public List<RegionDTO> getAllRegion(){
    return regionService.getAllRegion();
  }

  @GetMapping("/{id}")
  public RegionDTO getRegionById(@PathVariable Long id){
    return regionService.getRegionById(id);
  }
 
 @DeleteMapping("/{id}")
 public void deleteRegion(@PathVariable Long id){
    regionService.deleteRegion(id);
 }
}
