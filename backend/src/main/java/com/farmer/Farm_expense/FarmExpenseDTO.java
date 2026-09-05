package com.farmer.Farm_expense;

import java.time.LocalDate;

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
    private String expenseName;
    private Integer numberOfWorkers;
    private Float pricePerWorker;
    private Float teaOfCost;
    private Float cost135;
    private Float breackfastCost;
    private LocalDate expenseDate;
    private Float totalCost;

}
