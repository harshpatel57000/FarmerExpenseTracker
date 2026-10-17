
package com.farmer.add_region_page;


import com.farmer.Login_page.UserRepository;
import com.farmer.add_region_page.VillagePage.Village;
import com.farmer.add_region_page.VillagePage.VillageDTO;
import com.farmer.add_region_page.VillagePage.VillageRepository;
import com.farmer.add_region_page.VillagePage.VillageService;
import com.farmer.exception.ErrorException;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;

import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;

import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class VillageServiceTest {

    @Mock
    private VillageRepository villageRepository;

    @Mock
    private UserRepository userRepository;

    @InjectMocks
    private VillageService villageService;

    // 1. GET BY ID: village does not exist
    @Test
    void shouldThrowExceptionWhenVillageDoesNotExist() {

        when(villageRepository.findById(999L))
                .thenReturn(Optional.empty());

        assertThrows(ErrorException.class,() -> villageService.getVillageById(999L)
        );

        verify(villageRepository).findById(999L);
    }

    // 2. GET BY ID: village exists
    @Test
    void shouldReturnVillageWhenVillageExists() {

        Village village = new Village("Anand", "388001");
        village.setId(1L);

        when(villageRepository.findById(1L)).thenReturn(Optional.of(village));

        VillageDTO result = villageService.getVillageById(1L);

        assertEquals(1L, result.getId());
        assertEquals("Anand", result.getName());
        assertEquals("388001", result.getPinCode());

        verify(villageRepository).findById(1L);
    }

    // 3. GET ALL: multiple villages
    @Test
    void shouldReturnAllVillages() {

        Village village1 = new Village("Anand", "388001");
        village1.setId(1L);

        Village village2 = new Village("Nadiad", "387001");
        village2.setId(2L);

        when(villageRepository.findAll())
                .thenReturn(List.of(village1, village2));

        List<VillageDTO> result = villageService.getAllVillage();

        assertEquals(2, result.size());
        assertEquals("Anand", result.get(0).getName());
        assertEquals("Nadiad", result.get(1).getName());

        verify(villageRepository).findAll();
    }

    // 4. UPDATE: village exists
    @Test
    void shouldUpdateVillageWhenVillageExists() {

        Village village = new Village("Anand", "388001");
        village.setId(1L);

        VillageDTO updateDTO =
                new VillageDTO(1L, "Nadiad", "387001");

        when(villageRepository.findById(1L))
                .thenReturn(Optional.of(village));

        when(villageRepository.save(any(Village.class)))
                .thenAnswer(invocation -> invocation.getArgument(0));

        VillageDTO result =
                villageService.updateVillageName(1L, updateDTO);

        assertEquals(1L, result.getId());
        assertEquals("Nadiad", result.getName());
        assertEquals("387001", result.getPinCode());

        verify(villageRepository).save(village);
    }

    // 5. UPDATE: village does not exist
    @Test
    void shouldThrowExceptionWhenUpdatingMissingVillage() {

        VillageDTO updateDTO = new VillageDTO(999L, "Nadiad", "387001");

        when(villageRepository.findById(999L)).thenReturn(Optional.empty());

        assertThrows(ErrorException.class,() -> villageService.updateVillageName(999L, updateDTO));

        verify(villageRepository, never()).save(any(Village.class));
    }

    // 6. DELETE: verify repository call
    @Test
    void shouldDeleteVillage() {

        doNothing().when(villageRepository).deleteById(1L);

        villageService.deleteVillage(1L);

        verify(villageRepository).deleteById(1L);
    }

    // 7. ADD: logged-in user not found
    @Test
    void shouldThrowExceptionWhenAddVillageForMissingUser() {

        SecurityContextHolder.getContext().setAuthentication(
                new UsernamePasswordAuthenticationToken(
                        "farmer@example.com", "password"
                )
        );

        try {
            VillageDTO dto = new VillageDTO(null, "Anand", "388001");

            when(userRepository.findByEmailId("farmer@example.com")).thenReturn(Optional.empty());

            assertThrows(ErrorException.class,() -> villageService.addVillage(dto));

            verify(villageRepository, never()).save(any(Village.class));

        } finally {
            SecurityContextHolder.clearContext();
        }
    }
}
