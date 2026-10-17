
package com.farmer.Farm_expense;

import java.time.LocalDate;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@AllArgsConstructor
@NoArgsConstructor
@Data
@Builder
public class FarmExpenseDTO {

    private Long id;

    @NotNull(message = "Please enter the Farm ID")
    private Long farmId;

    private Long cropCycleId;

    @NotNull(message = "Please enter the Expense Type")
    private ExpenseType expenseType;

    @NotBlank(message = "Please enter the Expense Name")
    private String expenseName;

    // Required only for Agro Expense
    private Double agroQuantity;

    // Required only for Agro Expense
    private Double totalAgroExpense;

    private Double numberOfWorkers;

    private Double pricePerWorker;

    private Double totalExpenseOfWorkers;

    private Double extraCost;

    @NotNull(message = "Please enter the Expense Date")
    private LocalDate expenseDate;

    @NotNull(message = "Please enter the Total Cost")
    private Double totalCost;
}
