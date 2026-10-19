
package com.farmer.Farm_ExpenseTest;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.data.jpa.test.autoconfigure.DataJpaTest;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;

import com.farmer.Farm_expense.ExpenseType;
import com.farmer.Farm_expense.FarmExpense;
import com.farmer.Farm_expense.FarmExpenseRepository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;

@DataJpaTest
class FarmExpenseRepositoryTest {

    @Autowired
    private FarmExpenseRepository farmExpenseRepository;

    private FarmExpense createExpense(String name) {
        return FarmExpense.builder()
                .farmId(1L)
                .cropCycle(null)
                .expenseType(ExpenseType.NORMAL)
                .expenseName(name)
                .agroQuantity(null)
                .totalAgroExpense(null)
                .numberOfWorkers(2.0)
                .pricePerWorker(500.0)
                .totalExpenseOfWorkers(1000.0)
                .ExtraCost(100.0)
                .expenseDate(LocalDate.of(2026, 10, 18))
                .totalCost(1100.0)
                .build();
    }

    // 1. Save and find an expense by ID
    @Test
    void shouldSaveAndFindExpenseById() {
        FarmExpense saved =
                farmExpenseRepository.save(createExpense("Worker Payment"));

        Optional<FarmExpense> result =
                farmExpenseRepository.findById(saved.getId());

        assertTrue(result.isPresent());
        assertEquals("Worker Payment", result.get().getExpenseName());
        assertEquals(1L, result.get().getFarmId());
        assertEquals(1100.0, result.get().getTotalCost());
    }

    // 2. Find all expenses
    @Test
    void shouldFindAllExpenses() {
        farmExpenseRepository.save(createExpense("Worker Payment"));
        farmExpenseRepository.save(createExpense("Tea Cost"));

        List<FarmExpense> result = farmExpenseRepository.findAll();

        assertEquals(2, result.size());
    }

    // 3. Return empty when expense does not exist
    @Test
    void shouldReturnEmptyWhenExpenseDoesNotExist() {
        Optional<FarmExpense> result =
                farmExpenseRepository.findById(999L);

        assertTrue(result.isEmpty());
    }

    // 4. Delete an expense
    @Test
    void shouldDeleteExpense() {
        FarmExpense saved =
                farmExpenseRepository.save(createExpense("Worker Payment"));

        Long id = saved.getId();

        farmExpenseRepository.deleteById(id);
        farmExpenseRepository.flush();

        assertTrue(farmExpenseRepository.findById(id).isEmpty());
    }

    // 5. Search by crop name and crop-cycle date range
    // No crop cycles are created in this test, so the result should be empty.
    @Test
    void shouldReturnEmptyWhenNoCropCycleMatchesSearch() {
        Page<FarmExpense> result =
                farmExpenseRepository
                        .findByCropCycle_CropNameIgnoreCaseAndCropCycle_StartDateBetween(
                                "Wheat",
                                LocalDate.of(2026, 1, 1),
                                LocalDate.of(2026, 12, 31),
                                PageRequest.of(
                                        0, 20,
                                        Sort.by("expenseDate").descending()
                                )
                        );

        assertTrue(result.isEmpty());
    }
}
