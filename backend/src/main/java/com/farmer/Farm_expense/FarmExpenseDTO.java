package com.farmer.Farm_expense;

import java.time.LocalDate;

import io.micrometer.common.lang.NonNull;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Builder 
@Getter 
@Setter
@AllArgsConstructor 
@NoArgsConstructor 
public class FarmExpenseDTO {

    private Long id;

    @NotNull(message="!please,Enter Name of Expense")
    private String expenseName;

    @NotNull(message="!Please,Enter Number of Worker")
    private Integer numberOfWorkers;

    @NotNull(message="!Please,Enter Prise of given to Worker")
    private Float pricePerWorker;

    private Float teaOfCost;

    private Float cost135;

    private Float breackfastCost;

    @NotNull(message="!Please,Enter Date Of Expense")
    private LocalDate expenseDate;

    @NotNull(message="Give Total")
    private Float totalCost;

}
