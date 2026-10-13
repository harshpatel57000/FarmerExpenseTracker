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

}
