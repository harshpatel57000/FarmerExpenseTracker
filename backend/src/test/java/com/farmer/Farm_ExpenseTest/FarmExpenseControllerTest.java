
package com.farmer.Farm_ExpenseTest;

import com.farmer.Farm_expense.ExpenseType;
import com.farmer.Farm_expense.FarmExpenseController;
import com.farmer.Farm_expense.FarmExpenseDTO;
import com.farmer.Farm_expense.FarmExpenseService;
import com.farmer.Login_page.jwt_token.JwtService;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.WebMvcTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

import java.time.LocalDate;
import java.util.List;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(FarmExpenseController.class)
class FarmExpenseControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockitoBean
    private FarmExpenseService farmExpenseService;

    @MockitoBean
    private JwtService jwtService;

    // Converts a Java object into JSON without Spring injection.
    private String toJson(Object object) throws Exception {
        return new com.fasterxml.jackson.databind.ObjectMapper()
                .findAndRegisterModules()
                .writeValueAsString(object);
    }

    private FarmExpenseDTO createDTO() {
        FarmExpenseDTO dto = new FarmExpenseDTO();

        dto.setId(1L);
        dto.setFarmId(1L);
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

    @Test
    void shouldCreateExpense() throws Exception {
        FarmExpenseDTO dto = createDTO();

        when(farmExpenseService.addFarmExpense(any(FarmExpenseDTO.class)))
                .thenReturn(dto);

        mockMvc.perform(post("/api/farm_expense")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(dto)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(1))
                .andExpect(jsonPath("$.expenseName").value("Worker payment"));

        verify(farmExpenseService)
                .addFarmExpense(any(FarmExpenseDTO.class));
    }

    @Test
    void shouldGetAllExpenses() throws Exception {
        when(farmExpenseService.getAllFarmExpense())
                .thenReturn(List.of(createDTO()));

        mockMvc.perform(get("/api/farm_expense"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].expenseName")
                        .value("Worker payment"));
    }

    @Test
    void shouldGetExpenseById() throws Exception {
        when(farmExpenseService.getFarmExpenseById(1L))
                .thenReturn(createDTO());

        mockMvc.perform(get("/api/farm_expense/1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(1))
                .andExpect(jsonPath("$.expenseName")
                        .value("Worker payment"));
    }

    @Test
    void shouldUpdateExpense() throws Exception {
        FarmExpenseDTO dto = createDTO();
        dto.setExpenseName("Updated worker payment");

        when(farmExpenseService.updateFarmExpense(
                eq(1L), any(FarmExpenseDTO.class)))
                .thenReturn(dto);

        mockMvc.perform(put("/api/farm_expense/1")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(dto)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.expenseName")
                        .value("Updated worker payment"));
    }

    @Test
    void shouldPatchExpense() throws Exception {
        FarmExpenseDTO dto = createDTO();
        dto.setExpenseName("Patched expense");

        when(farmExpenseService.patchFarmExpense(
                eq(1L), any(FarmExpenseDTO.class)))
                .thenReturn(dto);

        mockMvc.perform(patch("/api/farm_expense/1")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(dto)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.expenseName")
                        .value("Patched expense"));
    }

    @Test
    void shouldDeleteExpense() throws Exception {
        doNothing().when(farmExpenseService)
                .deleteFarmExpense(1L);

        mockMvc.perform(delete("/api/farm_expense/1"))
                .andExpect(status().isOk());

        verify(farmExpenseService)
                .deleteFarmExpense(1L);
    }
}
