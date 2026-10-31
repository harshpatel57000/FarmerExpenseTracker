
package com.farmer.Farm_expense;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

public interface FarmExpenseRepository
        extends JpaRepository<FarmExpense, Long> {

    // Find one expense only when its farm ID is in the user's farm list
    Optional<FarmExpense> findByIdAndFarmIdIn(
            Long id,
            List<Long> farmIds
    );

    // Get expenses belonging to the user's farms
    List<FarmExpense> findByFarmIdIn(
            List<Long> farmIds
    );

    // Search only expenses belonging to the user's farms
    Page<FarmExpense>
    findByFarmIdInAndCropCycle_CropNameIgnoreCaseAndCropCycle_StartDateBetween(
            List<Long> farmIds,
            String cropName,
            LocalDate startDate,
            LocalDate endDate,
            Pageable pageable
    );
}
