package com.farmer.Farm_expense;

import java.time.LocalDate;
import org.springframework.data.domain.Page;

import org.springframework.data.domain.Pageable;

import org.springframework.data.jpa.repository.JpaRepository;



public interface FarmExpenseRepository extends JpaRepository<FarmExpense,Long>{

    Page<FarmExpense>findByCropCycle_CropNameIgnoreCaseAndCropCycle_StartDateBetween(
            String cropName,
            LocalDate startDate,
            LocalDate endDate,
            Pageable pageable
    );

    
}  
