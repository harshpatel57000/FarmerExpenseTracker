
package com.farmer.add_region_page;

import com.farmer.add_region_page.FarmPage.Farm;
import com.farmer.add_region_page.FarmPage.FarmDTO;
import com.farmer.add_region_page.FarmPage.FarmRepository;
import com.farmer.add_region_page.FarmPage.FarmService;
import com.farmer.add_region_page.RegionPage.Region;
import com.farmer.add_region_page.RegionPage.RegionRepository;
import com.farmer.add_region_page.VillagePage.Village;
import com.farmer.exception.ErrorException;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class FarmServiceTest {

    @Mock
    private FarmRepository farmRepository;

    @Mock
    private RegionRepository regionRepository;

    @InjectMocks
    private FarmService farmService;

    // 1. Add farm successfully
    @Test
    void shouldAddFarmSuccessfully() {
        Village village = new Village("Anand", "388001");
        village.setId(1L);

        Region region = new Region(2L, "North Region", village);
        FarmDTO dto = new FarmDTO(null, "Farm A", 2.5, 2L);

        Farm savedFarm = new Farm(10L, "Farm A", 2.5, region);

        when(regionRepository.findById(2L))
                .thenReturn(Optional.of(region));
        when(farmRepository.save(any(Farm.class)))
                .thenReturn(savedFarm);

        FarmDTO result = farmService.addFarm(dto);

        assertEquals(10L, result.getId());
        assertEquals("Farm A", result.getName());
        assertEquals(2.5, result.getArea());
        assertEquals(2L, result.getRegionId());

        verify(regionRepository).findById(2L);
        verify(farmRepository).save(any(Farm.class));
    }

    // 2. Adding farm fails if region does not exist
    @Test
    void shouldThrowExceptionWhenRegionDoesNotExist() {
        FarmDTO dto = new FarmDTO(null, "Farm A", 2.5, 99L);

        when(regionRepository.findById(99L))
                .thenReturn(Optional.empty());

        assertThrows(
                ErrorException.class,
                () -> farmService.addFarm(dto)
        );

        verify(farmRepository, never()).save(any(Farm.class));
    }

    // 3. Retrieve farm by ID
    @Test
    void shouldReturnFarmById() {
        Village village = new Village("Anand", "388001");
        village.setId(1L);

        Region region = new Region(2L, "North Region", village);
        Farm farm = new Farm(10L, "Farm A", 2.5, region);

        when(farmRepository.findById(10L))
                .thenReturn(Optional.of(farm));

        FarmDTO result = farmService.getFarmById(10L);

        assertEquals(10L, result.getId());
        assertEquals("Farm A", result.getName());
        assertEquals(2L, result.getRegionId());
    }

    // 4. Farm does not exist
    @Test
    void shouldThrowExceptionWhenFarmDoesNotExist() {
        when(farmRepository.findById(99L))
                .thenReturn(Optional.empty());

        assertThrows(
                ErrorException.class,
                () -> farmService.getFarmById(99L)
        );
    }

    // 5. Retrieve all farms
    @Test
    void shouldReturnAllFarms() {
        Village village = new Village("Anand", "388001");
        village.setId(1L);

        Region region = new Region(2L, "North Region", village);

        Farm farm1 = new Farm(10L, "Farm A", 2.5, region);
        Farm farm2 = new Farm(11L, "Farm B", 3.0, region);

        when(farmRepository.findAll())
                .thenReturn(List.of(farm1, farm2));

        List<FarmDTO> result = farmService.getAllFarm();

        assertEquals(2, result.size());
        assertEquals("Farm A", result.get(0).getName());
        assertEquals("Farm B", result.get(1).getName());
    }

    // 6. Delete farm
    @Test
    void shouldDeleteFarm() {
        farmService.deletefarm(10L);

        verify(farmRepository).deleteById(10L);
    }
}

