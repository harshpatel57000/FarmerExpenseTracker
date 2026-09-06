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

    

}
