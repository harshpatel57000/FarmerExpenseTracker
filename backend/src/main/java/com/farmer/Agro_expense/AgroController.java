package com.farmer.Agro_expense;

import lombok.RequiredArgsConstructor;

import java.util.List;

import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/agro")
@RequiredArgsConstructor
public class AgroController {

    private final AgroService agroService;

    @PostMapping
    public AgroDTO addAgro(@Valid @RequestBody AgroDTO dto) {
        return agroService.addAgro(dto);
    }

    @GetMapping
    public List<AgroDTO> getAllAgro(){
        return agroService.getAllAgro();
    }

    @GetMapping("/{id}")
    public AgroDTO getAgroById(@Valid @PathVariable Long id){
        return agroService.getAgroById(id);
    }

    @PutMapping("/{id}")
    public AgroDTO putAgroDTO(@Valid @PathVariable Long id,@RequestBody AgroDTO dto){
        return agroService.putAgro(id,dto);
    }
    @PatchMapping("/{id}")
    public AgroDTO patchAgroDTO(@Valid @PathVariable Long id,@RequestBody AgroDTO dto){
        return agroService.patchAgro(id,dto);
    }
    @DeleteMapping("/{id}")
    public void deleteAgro(@Valid @PathVariable Long id){
        agroService.deleteAgro(id);
    }

}   