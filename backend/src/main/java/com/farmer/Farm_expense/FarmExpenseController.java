package com.farmer.Farm_expense;

import java.util.List;

import org.springframework.data.domain.Page;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jakarta.validation.Valid;
import lombok.AllArgsConstructor;
import lombok.RequiredArgsConstructor;

@AllArgsConstructor 
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

    @GetMapping("/{id:\\d+}")
    public FarmExpenseDTO getFarmExpenseById(
            @PathVariable Long id) {
        return farmExpenseService.getFarmExpenseById(id);
    }

    @PutMapping("/{id:\\d+}")
    public FarmExpenseDTO updateFarmExpense(
            @PathVariable Long id,
            @Valid @RequestBody FarmExpenseDTO dto) {
        return farmExpenseService.updateFarmExpense(id, dto);
    }

    @PatchMapping("/{id:\\d+}")
    public FarmExpenseDTO patchFarmExpense(
            @PathVariable Long id,
            @RequestBody FarmExpenseDTO dto) {
        return farmExpenseService.patchFarmExpense(id, dto);
    }

    @DeleteMapping("/{id:\\d+}")
    public void deleteFarmExpense(@PathVariable Long id) {
        farmExpenseService.deleteFarmExpense(id);
    }

    // Add inside FarmExpenseController.

    @GetMapping("/search")
    public Page<FarmExpenseDTO> searchFarmExpenses(
        @RequestParam String cropName,
        @RequestParam int year,
        @RequestParam(defaultValue = "0") int page,
        @RequestParam(defaultValue = "20") int size,
        @RequestParam(defaultValue = "expenseDate") String sortBy,
        @RequestParam(defaultValue = "desc") String direction) {

    return farmExpenseService.searchFarmExpenses(
            cropName,
            year,
            page,
            size,
            sortBy,
            direction
    );
}
}


