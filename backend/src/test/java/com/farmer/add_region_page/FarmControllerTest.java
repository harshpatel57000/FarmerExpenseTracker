package com.farmer.add_region_page;

import com.farmer.Login_page.jwt_token.JwtService;
import com.farmer.add_region_page.FarmPage.FarmController;
import com.farmer.add_region_page.FarmPage.FarmDTO;
import com.farmer.add_region_page.FarmPage.FarmService;
import com.fasterxml.jackson.databind.ObjectMapper;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.security.autoconfigure.SecurityAutoConfiguration;
import org.springframework.boot.security.autoconfigure.web.servlet.SecurityFilterAutoConfiguration;
import org.springframework.boot.webmvc.test.autoconfigure.WebMvcTest;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.util.List;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(
    controllers = FarmController.class,
    excludeAutoConfiguration = {
        SecurityAutoConfiguration.class,
        SecurityFilterAutoConfiguration.class
    }
)
class FarmControllerTest {

    @Autowired
    private MockMvc mockMvc;

    // Use a local mapper instead of injecting ObjectMapper.
    private final ObjectMapper objectMapper = new ObjectMapper();

    @MockitoBean
    private FarmService farmService;

    // The JWT filter may require this bean in the test context.
    @MockitoBean
    private JwtService jwtService;

    private FarmDTO createDTO() {
        return new FarmDTO(1L, "North Farm", 2.5, 1L);
    }

    @Test
    void shouldAddFarm() throws Exception {
        FarmDTO dto = createDTO();

        when(farmService.addFarm(any(FarmDTO.class)))
                .thenReturn(dto);

        mockMvc.perform(post("/api/farm")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(dto)))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.id").value(1))
            .andExpect(jsonPath("$.name").value("North Farm"))
            .andExpect(jsonPath("$.area").value(2.5))
            .andExpect(jsonPath("$.regionId").value(1));

        verify(farmService).addFarm(any(FarmDTO.class));
    }

    @Test
    void shouldGetAllFarms() throws Exception {
        when(farmService.getAllFarm())
                .thenReturn(List.of(createDTO()));

        mockMvc.perform(get("/api/farm"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$[0].id").value(1))
            .andExpect(jsonPath("$[0].name").value("North Farm"))
            .andExpect(jsonPath("$[0].area").value(2.5))
            .andExpect(jsonPath("$[0].regionId").value(1));

        verify(farmService).getAllFarm();
    }

    @Test
    void shouldGetFarmById() throws Exception {
        when(farmService.getFarmById(1L))
                .thenReturn(createDTO());

        mockMvc.perform(get("/api/farm/1"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.id").value(1))
            .andExpect(jsonPath("$.name").value("North Farm"))
            .andExpect(jsonPath("$.area").value(2.5))
            .andExpect(jsonPath("$.regionId").value(1));

        verify(farmService).getFarmById(1L);
    }

    @Test
    void shouldDeleteFarm() throws Exception {
        doNothing().when(farmService).deletefarm(1L);

        mockMvc.perform(delete("/api/farm/1"))
            .andExpect(status().isOk())
            .andExpect(content().string("delete farm complete"));

        verify(farmService).deletefarm(1L);
    }
}
