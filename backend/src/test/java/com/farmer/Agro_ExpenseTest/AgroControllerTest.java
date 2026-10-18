package com.farmer.Agro_ExpenseTest;

import com.farmer.Agro_expense.AgroController;
import com.farmer.Agro_expense.AgroDTO;
import com.farmer.Agro_expense.AgroService;
import com.farmer.Agro_expense.ValueUnitDTO;
import com.farmer.Login_page.jwt_token.JwtService;
import com.fasterxml.jackson.databind.ObjectMapper;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.WebMvcTest;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.time.LocalDate;
import java.util.List;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(AgroController.class)
class AgroControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockitoBean
    private AgroService agroService;

    @MockitoBean
    private JwtService jwtService;


    private String toJson(Object object) throws Exception {
    return new com.fasterxml.jackson.databind.ObjectMapper()
            .findAndRegisterModules()
            .writeValueAsString(object);
}

    private AgroDTO createDTO() {
    return AgroDTO.builder()
            .id(1L)
            .userId(1L)
            .productName("Fertilizer")
            .quantity(new ValueUnitDTO())
            .measurement(new ValueUnitDTO())
            .pricePerUnit(100.0f)
            .totalWeight(new ValueUnitDTO())
            .totalAmount(500.0f)
            .purchaseDate(LocalDate.of(2026, 10, 18))
            .build();
}

    @Test
    void shouldAddAgro() throws Exception {
        AgroDTO dto = createDTO();

        when(agroService.addAgro(any(AgroDTO.class)))
                .thenReturn(dto);

        mockMvc.perform(post("/api/agro")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(dto))) 
                        .andDo(org.springframework.test.web.servlet.result.MockMvcResultHandlers.print())         
                        .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(1))
                .andExpect(jsonPath("$.productName").value("Fertilizer"));

        verify(agroService).addAgro(any(AgroDTO.class));
    }

    @Test
    void shouldGetAllAgro() throws Exception {
        when(agroService.getAllAgro())
                .thenReturn(List.of(createDTO()));

        mockMvc.perform(get("/api/agro"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].productName").value("Fertilizer"));
    }

    @Test
    void shouldGetAgroById() throws Exception {
        when(agroService.getAgroById(1L))
                .thenReturn(createDTO());

        mockMvc.perform(get("/api/agro/1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(1))
                .andExpect(jsonPath("$.productName").value("Fertilizer"));
    }

    @Test
    void shouldPutAgro() throws Exception {
        AgroDTO dto = createDTO();
        dto.setProductName("Updated Fertilizer");

        when(agroService.putAgro(eq(1L), any(AgroDTO.class)))
                .thenReturn(dto);

        mockMvc.perform(put("/api/agro/1")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(dto)))
                        .andExpect(status().isOk())
                .andExpect(jsonPath("$.productName")
                        .value("Updated Fertilizer"));
    }

    @Test
    void shouldPatchAgro() throws Exception {
        AgroDTO dto = createDTO();
        dto.setProductName("Patched Fertilizer");

        when(agroService.patchAgro(eq(1L), any(AgroDTO.class)))
                .thenReturn(dto);

        mockMvc.perform(patch("/api/agro/1")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(dto)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.productName")
                        .value("Patched Fertilizer"));
    }

    @Test
    void shouldDeleteAgro() throws Exception {
        mockMvc.perform(delete("/api/agro/1"))
                .andExpect(status().isOk());

        verify(agroService).deleteAgro(1L);
    }
}