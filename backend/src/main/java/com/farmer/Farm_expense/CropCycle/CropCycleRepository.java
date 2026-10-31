package com.farmer.Farm_expense.CropCycle;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;


public interface CropCycleRepository extends JpaRepository<CropCycle,Long>{

    List<CropCycle> findByFarm_IdOrderByStartDateDesc(Long farmId);

    Optional<CropCycle> findByIdAndFarmUserId(Long id,Long userId);

}
