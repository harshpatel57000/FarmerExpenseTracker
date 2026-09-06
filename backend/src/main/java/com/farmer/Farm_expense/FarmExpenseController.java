package com.farmer.Farm_expense;

import java.util.List;

import org.springframework.web.bind.annotation.*;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import lombok.RequiredArgsConstructor;

@RequiredArgsConstructor 
@RestController
@RequestMapping("/api/farm_expense") 
public class FarmExpenseController {
    public final FarmExpenseService farmExpenseService;

    @PostMapping
    public FarmExpenseDTO saveFarmExpense(@RequestBody FarmExpenseDTO dto){
        return farmExpenseService.saveFarmExpense(dto);
    }

    @GetMapping
    public List<FarmExpenseDTO> getFarmExpense(){
        return farmExpenseService.getFarmExpense();
    }

    @GetMapping("/{id}")
    public FarmExpenseDTO getFarmExpenseById(@PathVariable Long id){
        return farmExpenseService.getFarmExpenseById(id);
    }

}
