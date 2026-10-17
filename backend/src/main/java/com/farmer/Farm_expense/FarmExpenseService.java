package com.farmer.Farm_expense;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;

import org.springframework.stereotype.*;

import com.farmer.Farm_expense.CropCycle.CropCycle;
import com.farmer.Farm_expense.CropCycle.CropCycleRepository;
import com.farmer.exception.ErrorException;

import java.time.LocalDate;
import java.util.List;
import java.util.Set;

import lombok.AllArgsConstructor;

@AllArgsConstructor 
@Service
public class FarmExpenseService {

    public final FarmExpenseRepository farmExpenseRepository;
    public final CropCycleRepository cropCycleRepository;

    //POST
    public FarmExpenseDTO saveFarmExpense(FarmExpenseDTO dto){
        FarmExpense entity =FarmExpenseMapper.toEntity(dto);

        if(dto.getCropCycleId() != null){
            CropCycle cropCycle =cropCycleRepository.findById(dto.getCropCycleId()).orElseThrow(()->new ErrorException("CropCycle not fround"));
            
            if(!cropCycle.getFarm().getId().equals(dto.getFarmId())){
                throw new ErrorException("Crop cycle does not belong to the specified farm");
            }
            entity.setCropCycle(cropCycle);
        }
        return FarmExpenseMapper.toDTO(farmExpenseRepository.save(entity));
    }

    //GET 
    public List<FarmExpenseDTO> getFarmExpense(){
        List<FarmExpense> farmExpenseList=farmExpenseRepository.findAll();
        return farmExpenseList.stream().map(FarmExpenseMapper::toDTO).toList();
    }
    
    //GET BY ID
    public FarmExpenseDTO getFarmExpenseById(long id){
        FarmExpense farmExpense=farmExpenseRepository.findById(id).orElseThrow(()->new ErrorException("Fram Expense NotFound"));
        return FarmExpenseMapper.toDTO(farmExpense);
    }

    //PUT 
    public FarmExpenseDTO updateFarmExpense(Long id,FarmExpenseDTO dto){
        FarmExpense entity=farmExpenseRepository.findById(id).orElseThrow(()->new ErrorException("Farm Expese NotFound"));

        
                entity.setExpenseType(dto.getExpenseType());
                entity.setExpenseName(dto.getExpenseName());
                entity.setAgroQuantity(dto.getAgroQuantity());
                entity.setTotalAgroExpense(dto.getTotalAgroExpense());
                entity.setNumberOfWorkers(dto.getNumberOfWorkers());
                entity.setPricePerWorker(dto.getPricePerWorker());
                entity.setTotalExpenseOfWorkers(dto.getTotalExpenseOfWorkers());
                entity.setExtraCost(dto.getExtraCost());
                entity.setExpenseDate(dto.getExpenseDate());
                entity.setTotalCost(dto.getTotalCost());

                FarmExpense updateEntity=farmExpenseRepository.save(entity);
        return FarmExpenseMapper.toDTO(updateEntity);
    }

    //PATCH
    public FarmExpenseDTO patchFarmExpense(Long id,FarmExpenseDTO dto){
        FarmExpense entity=farmExpenseRepository.findById(id).orElseThrow(()->new ErrorException("Farm Expense Nopt FOund"));

        if(dto.getExpenseType() != null){
            entity.setExpenseType(dto.getExpenseType());
        }

        if(dto.getExpenseName() != null){
            entity.setExpenseName(dto.getExpenseName());
        }


        if(dto.getAgroQuantity() != null){
            entity.setAgroQuantity(dto.getAgroQuantity());
        }

        if(dto.getTotalAgroExpense() != null){
            entity.setTotalAgroExpense(dto.getTotalAgroExpense());
        }

        
        if(dto.getNumberOfWorkers() != null){
            entity.setNumberOfWorkers(dto.getNumberOfWorkers());
        }

        if(dto.getPricePerWorker() != null){
            entity.setPricePerWorker(dto.getPricePerWorker());
        }

        if(dto.getTotalExpenseOfWorkers() != null){
            entity.setTotalExpenseOfWorkers(dto.getTotalExpenseOfWorkers());
        }   
        
        if(dto.getExtraCost()!=null){
            entity.setExtraCost(dto.getExtraCost());
        }

        if(dto.getExpenseDate() != null){
            entity.setExpenseDate(dto.getExpenseDate());
        }

        if(dto.getTotalCost() != null){
            entity.setTotalCost(dto.getTotalCost());
        }

        FarmExpense updatedEntity = farmExpenseRepository.save(entity);

        return FarmExpenseMapper.toDTO(updatedEntity);
    }
    
    //DELETE
    public void deleteFarmExpense(Long id){
        farmExpenseRepository.deleteById(id);
    }



// Add this method inside your existing FarmExpenseService class.

public Page<FarmExpenseDTO> searchFarmExpenses(
        String cropName,
        int year,
        int page,
        int size,
        String sortBy,
        String direction) {

    if (cropName == null || cropName.isBlank()) {
        throw new IllegalArgumentException("Crop name is required");
    }

    if (year < 2000 || year > 2100) {
        throw new IllegalArgumentException("Invalid year");
    }

    if (page < 0) {
        throw new IllegalArgumentException("Page cannot be negative");
    }

    if (size < 1 || size > 100) {
        throw new IllegalArgumentException(
                "Page size must be between 1 and 100");
    }

    Set<String> allowedSortFields = Set.of(
            "id",
            "expenseDate",
            "expenseName",
            "totalCost"
    );

    if (sortBy == null || !allowedSortFields.contains(sortBy)) {
        sortBy = "expenseDate";
    }

    Sort sort = "asc".equalsIgnoreCase(direction)
            ? Sort.by(sortBy).ascending()
            : Sort.by(sortBy).descending();

    Pageable pageable = PageRequest.of(page, size, sort);

    LocalDate startDate = LocalDate.of(year, 1, 1);
    LocalDate endDate = LocalDate.of(year, 12, 31);

    Page<FarmExpense> expensePage =farmExpenseRepository.findByCropCycle_CropNameIgnoreCaseAndCropCycle_StartDateBetween(
                            cropName.trim(),
                            startDate,
                            endDate,
                            pageable
                    );

    return expensePage.map(FarmExpenseMapper::toDTO);
}


}
