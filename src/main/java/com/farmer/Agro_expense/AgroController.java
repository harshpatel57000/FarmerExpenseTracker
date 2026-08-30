package com.farmer.Agro_expense;

import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/agro")
@RequiredArgsConstructor
public class AgroController {

    private final AgroService agroservice;

    @PostMapping
    public AgroDTO addAgro(@RequestBody AgroDTO dto) {
        return agroservice.addAgro(dto);
    }
}