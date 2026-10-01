package com.farmer.Farm_expense;

import java.time.LocalDate;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity 
@Table(name ="farm_expenses")
@Builder 
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
    private Integer numberOfWorkers;

    @Column(name="price_per_worker",nullable=false)
    private Float pricePerWorker;

    @Column(name="moreCost",nullable=true)
    private Float ExtraCost;


    @Column(name="date",nullable=false)
    private LocalDate expenseDate;

    @Column(name="total_cost",nullable=false)
    private Float totalCost;    

}
