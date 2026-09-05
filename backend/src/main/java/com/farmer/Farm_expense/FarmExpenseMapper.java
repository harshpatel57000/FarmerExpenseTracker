package com.farmer.Farm_expense;

import com.farmer.Farm_expense.FarmExpenseDTO;

import lombok.Builder;

@Builder
public class FarmExpenseMapper {
    //toENTITY
    public static FarmExpense toEntity(FarmExpenseDTO dto){
        return FarmExpense.builder()
                .id(dto.getId())
                .expenseName(dto.getExpenseName())
                .numberOfWorkers(dto.getNumberOfWorkers())
                .pricePerWorker(dto.getPricePerWorker())
                .teaOfCost(dto.getTeaOfCost())
                .cost135(dto.getCost135())
                .breackfastCost(dto.getBreackfastCost())
                .expenseDate(dto.getExpenseDate())
                .totalCost(dto.getTotalCost()).build();
    }

    //toDTO
    public static FarmExpenseDTO toDTO(FarmExpense entity){
        return FarmExpenseDTO.builder()
                .expenseName(entity.getExpenseName())
                .numberOfWorkers(entity.getNumberOfWorkers())
                .pricePerWorker(entity.getPricePerWorker())
                .teaOfCost(entity.getTeaOfCost())
                .cost135(entity.getCost135())
                .breackfastCost(entity.getBreackfastCost())
                .expenseDate(entity.getExpenseDate())
                .totalCost(entity.getTotalCost()).build();  
    }

}
