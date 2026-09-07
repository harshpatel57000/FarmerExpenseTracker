package com.farmer.Farm_expense;

import java.util.List;

import org.springframework.web.bind.annotation.*;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@RequiredArgsConstructor 
@RestController
@RequestMapping("/api/farm_expense") 
public class FarmExpenseController {
    public final FarmExpenseService farmExpenseService;

    @PostMapping
    public FarmExpenseDTO saveFarmExpense(@Valid @RequestBody FarmExpenseDTO dto){
        return farmExpenseService.saveFarmExpense(dto);
    }

    @GetMapping
    public List<FarmExpenseDTO> getFarmExpense(){
        return farmExpenseService.getFarmExpense();
    }

    @GetMapping("/{id}")
    public FarmExpenseDTO getFarmExpenseById(@Valid @PathVariable Long id){
        return farmExpenseService.getFarmExpenseById(id);
    }

    @PutMapping("/{id}")
    public FarmExpenseDTO updateFarmExpense(@Valid @PathVariable Long id,@RequestBody FarmExpenseDTO dto){
        return farmExpenseService.updateFarmExpense(id,dto);
    }

    @PatchMapping("/{id}")
    public FarmExpenseDTO patchFarmExpense(@Valid @PathVariable Long id,@RequestBody FarmExpenseDTO dto){
        return farmExpenseService.patchFarmExpense(id,dto);
    }

    @DeleteMapping 
    public void deleteFarmExpense(@Valid @PathVariable Long id){
        farmExpenseService.deleteFarmExpense(id);
    }
    
}
