package com.farmer.Farm_expense;

import org.springframework.stereotype.*;

import com.farmer.exception.ErrorException;

import java.util.List;

import lombok.AllArgsConstructor;

@AllArgsConstructor 
@Service
public class FarmExpenseService {

    public final FarmExpenseRepository farmExpenseRepository;

    //POST
    public FarmExpenseDTO saveFarmExpense(FarmExpenseDTO dto){
        return FarmExpenseMapper.toDTO(farmExpenseRepository.save(FarmExpenseMapper.toEntity(dto)));
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

        entity.setExpenseName(dto.getExpenseName());
        entity.setNumberOfWorkers(dto.getNumberOfWorkers());
        entity.setPricePerWorker(dto.getPricePerWorker());
        entity.setTeaOfCost(dto.getTeaOfCost());
        entity.setBreackfastCost(dto.getBreackfastCost());
        entity.setCost135(dto.getCost135());
        entity.setExpenseDate(dto.getExpenseDate());
        entity.setTotalCost(dto.getTotalCost());
        return FarmExpenseMapper.toDTO(entity);
    }

    //PATCH
    public FarmExpenseDTO patchFarmExpense(Long id,FarmExpenseDTO dto){
        FarmExpense entity=farmExpenseRepository.findById(id).orElseThrow(()->new ErrorException("Farm Expense Nopt FOund"));

        if(dto.getExpenseName() != null){
            entity.setExpenseName(dto.getExpenseName());
        }
        
        if(dto.getNumberOfWorkers() != null){
            entity.setNumberOfWorkers(dto.getNumberOfWorkers());
        }

        if(dto.getPricePerWorker() != null){
            entity.setPricePerWorker(dto.getPricePerWorker());
        }

        if(dto.getTeaOfCost() != null){
            entity.setTeaOfCost(dto.getTeaOfCost());
        }

        if(dto.getCost135() != null){
            entity.setCost135(dto.getCost135());
        }
        
        if(dto.getBreackfastCost() !=null){
            entity.setBreackfastCost(dto.getBreackfastCost());
        }

        if(dto.getExpenseDate() != null){
            entity.setExpenseDate(dto.getExpenseDate());
        }

        if(dto.getTotalCost() != null){
            entity.setTotalCost(dto.getTotalCost());
        }

        return FarmExpenseMapper.toDTO(entity);
    }
    
    //DELETE
    public void deleteFarmExpense(Long id){
        farmExpenseRepository.deleteById(id);
    }

}
