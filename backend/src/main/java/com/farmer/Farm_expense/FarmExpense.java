package com.farmer.Farm_expense;

import java.time.LocalDate;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity 
@Table(name ="farm_expenses")
@Data
@Setter 
@Getter
@AllArgsConstructor 
@NoArgsConstructor 
public class FarmExpense {
    @Id 
    @GeneratedValue(strategy=GenerationType.IDENTITY)
    private Long id;
    
    @Column(name="expense_name", nullable=false)
    private String expenseName;

    @Column(name="worker_number",nullable=false)
    private Integer workerNumber;

    @Column(name="price_per_worker",nullable=false)
    private Float pricePerWorker;

    @Column(name="tea_of_cost",nullable=true)
    private Float teaOfCost;

    @Column(name="135_cost",nullable=true)
    private Float cost135;

    @Column (name="breack_fast_cost",nullable=true)
    private Float breackFastCost;

    @Column(name="date",nullable=false)
    private LocalDate ExpenseDate;

    @Column(name="total_cost",nullable=false)
    private Float totalCost;    

}
