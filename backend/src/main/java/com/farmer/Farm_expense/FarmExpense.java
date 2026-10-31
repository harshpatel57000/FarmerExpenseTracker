package com.farmer.Farm_expense;

import java.time.LocalDate;

import com.farmer.Farm_expense.CropCycle.CropCycle;

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

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "crop_cycle_id")
    private CropCycle cropCycle;

    @Column(name="farm_id",nullable=false)
    private Long farmId;

    @Enumerated(EnumType.STRING)
    @Column(name="expense-type",nullable=false)
    private ExpenseType expenseType;

    
    @Column(name="expense_name", nullable=false)
    private String expenseName;

   
    @Column(name="Agroquantity",nullable=true)
    private Double agroQuantity;

    @Column(name="total_agro_expense",nullable=true)
    private Double totalAgroExpense;
    
    
    @Column(name="worker_number",nullable=true)
    private Double numberOfWorkers;

    @Column(name="price_per_worker",nullable=true)
    private Double pricePerWorker;

    @Column(name="total_worker_Expense",nullable=true)
    private Double totalExpenseOfWorkers;
    
    
    @Column(name="ExtraCost",nullable=true)
    private Double ExtraCost;
    
    
    @Column(name="date",nullable=false)
    private LocalDate expenseDate;
    @Column(name="total_cost",nullable=false)
    private Double totalCost;    

}
