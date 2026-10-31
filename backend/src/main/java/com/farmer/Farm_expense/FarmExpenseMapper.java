
package com.farmer.Farm_expense;

import lombok.Builder;

@Builder
public class FarmExpenseMapper {

    // Convert DTO received from Flutter into a database entity.
    public static FarmExpense toEntity(FarmExpenseDTO dto) {
        return FarmExpense.builder()
                .id(dto.getId())
                .farmId(dto.getFarmId()) // Important: save farm ID
                .expenseType(dto.getExpenseType())
                .expenseName(dto.getExpenseName())
                .agroQuantity(dto.getAgroQuantity())
                .totalAgroExpense(dto.getTotalAgroExpense())
                .numberOfWorkers(dto.getNumberOfWorkers())
                .pricePerWorker(dto.getPricePerWorker())
                .totalExpenseOfWorkers(dto.getTotalExpenseOfWorkers())
                .ExtraCost(dto.getExtraCost())
                .expenseDate(dto.getExpenseDate())
                .totalCost(dto.getTotalCost())
                .build();
    }

    // Convert database entity into the response sent to Flutter.
    public static FarmExpenseDTO toDTO(FarmExpense entity) {
        return FarmExpenseDTO.builder()
                .id(entity.getId())
                .farmId(entity.getFarmId()) // Return farm ID
                .cropCycleId(entity.getCropCycle() != null? entity.getCropCycle().getId(): null)
                .expenseType(entity.getExpenseType())
                .expenseName(entity.getExpenseName())
                .agroQuantity(entity.getAgroQuantity())
                .totalAgroExpense(entity.getTotalAgroExpense())
                .numberOfWorkers(entity.getNumberOfWorkers())
                .pricePerWorker(entity.getPricePerWorker())
                .totalExpenseOfWorkers(entity.getTotalExpenseOfWorkers())
                .extraCost(entity.getExtraCost())
                .expenseDate(entity.getExpenseDate())
                .totalCost(entity.getTotalCost())
                .build();
    }
}
