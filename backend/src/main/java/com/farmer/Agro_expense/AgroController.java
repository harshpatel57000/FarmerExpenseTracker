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
}