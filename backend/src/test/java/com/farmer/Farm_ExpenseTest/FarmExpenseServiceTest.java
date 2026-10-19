package com.farmer.Farm_ExpenseTest;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;

import com.farmer.Farm_expense.ExpenseType;
import com.farmer.Farm_expense.FarmExpense;
import com.farmer.Farm_expense.FarmExpenseDTO;
import com.farmer.Farm_expense.FarmExpenseRepository;
import com.farmer.Farm_expense.FarmExpenseService;
import com.farmer.Farm_expense.CropCycle.CropCycleRepository;
import com.farmer.exception.ErrorException;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class FarmExpenseServiceTest {

    @Mock
    private FarmExpenseRepository farmExpenseRepository;

    @Mock
    private CropCycleRepository cropCycleRepository;

    @InjectMocks
    private FarmExpenseService farmExpenseService;

    private FarmExpenseDTO createDTO() {
        FarmExpenseDTO dto = new FarmExpenseDTO();
        dto.setFarmId(1L);
        dto.setCropCycleId(null);
        dto.setExpenseType(ExpenseType.NORMAL);
        dto.setExpenseName("Worker payment");
        dto.setNumberOfWorkers(2.0);
        dto.setPricePerWorker(500.0);
        dto.setTotalExpenseOfWorkers(1000.0);
        dto.setExtraCost(100.0);
        dto.setExpenseDate(LocalDate.of(2026, 10, 18));
        dto.setTotalCost(1100.0);
        return dto;
    }

    private FarmExpense createEntity() {
        return FarmExpense.builder()
                .id(1L)
                .farmId(1L)
                .cropCycle(null)
                .expenseType(ExpenseType.NORMAL)
                .expenseName("Worker payment")
                .numberOfWorkers(2.0)
                .pricePerWorker(500.0)
                .totalExpenseOfWorkers(1000.0)
                .ExtraCost(100.0)
                .expenseDate(LocalDate.of(2026, 10, 18))
                .totalCost(1100.0)
                .build();
    }

    @Test
    void shouldSaveExpenseWithoutCropCycle() {
        FarmExpenseDTO dto = createDTO();

        when(farmExpenseRepository.save(any(FarmExpense.class)))
                .thenAnswer(invocation -> {
                    FarmExpense expense = invocation.getArgument(0);
                    expense.setId(1L);
                    return expense;
                });

        FarmExpenseDTO result = farmExpenseService.addFarmExpense(dto);

        assertNotNull(result);
        assertEquals(1L, result.getId());
        assertEquals("Worker payment", result.getExpenseName());

        verify(farmExpenseRepository).save(any(FarmExpense.class));
        verifyNoInteractions(cropCycleRepository);
    }

    @Test
    void shouldGetAllExpenses() {
        when(farmExpenseRepository.findAll())
                .thenReturn(List.of(createEntity()));

        List<FarmExpenseDTO> result =
                farmExpenseService.getAllFarmExpense();

        assertEquals(1, result.size());
        assertEquals("Worker payment", result.get(0).getExpenseName());
    }

    @Test
    void shouldGetExpenseById() {
        when(farmExpenseRepository.findById(1L))
                .thenReturn(Optional.of(createEntity()));

        FarmExpenseDTO result =
                farmExpenseService.getFarmExpenseById(1L);

        assertEquals(1L, result.getId());
        assertEquals("Worker payment", result.getExpenseName());
    }

    @Test
    void shouldThrowWhenExpenseDoesNotExist() {
        when(farmExpenseRepository.findById(99L))
                .thenReturn(Optional.empty());

        assertThrows(ErrorException.class,() -> farmExpenseService.getFarmExpenseById(99L));
    }

    @Test
   void shouldDeleteExpense() {
    farmExpenseService.deleteFarmExpense(1L);

    verify(farmExpenseRepository).deleteById(1L);
    }

    @Test
    void shouldSearchExpenses() {
        Page<FarmExpense> page =
                new PageImpl<>(List.of(createEntity()));

        when(farmExpenseRepository
                .findByCropCycle_CropNameIgnoreCaseAndCropCycle_StartDateBetween(
                        eq("Wheat"),
                        eq(LocalDate.of(2026, 1, 1)),
                        eq(LocalDate.of(2026, 12, 31)),
                        any(PageRequest.class)))
                .thenReturn(page);

        Page<FarmExpenseDTO> result =
                farmExpenseService.searchFarmExpenses(
                        "Wheat", 2026, 0, 10,
                        "expenseDate", "desc"
                );

        assertEquals(1, result.getTotalElements());
        assertEquals("Worker payment",
                result.getContent().get(0).getExpenseName());
    }

    @Test
    void shouldRejectBlankCropName() {
        assertThrows(
                IllegalArgumentException.class,
                () -> farmExpenseService.searchFarmExpenses(
                        " ", 2026, 0, 10,
                        "expenseDate", "desc"
                )
        );
    }

    @Test
    void shouldRejectInvalidYear() {
        assertThrows(
                IllegalArgumentException.class,
                () -> farmExpenseService.searchFarmExpenses(
                        "Wheat", 1999, 0, 10,
                        "expenseDate", "desc"
                )
        );
    }
}