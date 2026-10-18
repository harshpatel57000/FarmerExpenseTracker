
package com.farmer.add_region_page;

import com.farmer.add_region_page.RegionPage.Region;
import com.farmer.add_region_page.RegionPage.RegionDTO;
import com.farmer.add_region_page.RegionPage.RegionRepository;
import com.farmer.add_region_page.RegionPage.RegionService;
import com.farmer.add_region_page.VillagePage.Village;
import com.farmer.add_region_page.VillagePage.VillageRepository;
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
class RegionServiceTest {

    @Mock
    private RegionRepository regionRepository;

    @Mock
    private VillageRepository villageRepository;

    @InjectMocks
    private RegionService regionService;

    // 1. Test adding a region successfully
    @Test
    void shouldAddRegionSuccessfully() {
        Village village = new Village("Anand", "388001");
        village.setId(1L);

        RegionDTO dto = new RegionDTO(null, "North Region", 1L);
        Region savedRegion = new Region(5L, "North Region", village);

        when(villageRepository.findById(1L)).thenReturn(Optional.of(village));

        when(regionRepository.save(any(Region.class))).thenReturn(savedRegion);

        RegionDTO result = regionService.addRegion(dto);

        assertEquals(5L, result.getId());
        assertEquals("North Region", result.getName());
        assertEquals(1L, result.getVillageId());

        verify(villageRepository).findById(1L);
        verify(regionRepository).save(any(Region.class));
    }

    // 2. Test adding a region when the village does not exist
    @Test
    void shouldThrowExceptionWhenVillageDoesNotExist() {
        RegionDTO dto = new RegionDTO(null, "North Region", 99L);

        when(villageRepository.findById(99L)).thenReturn(Optional.empty());

        assertThrows(ErrorException.class,() -> regionService.addRegion(dto));

        verify(regionRepository, never()).save(any(Region.class));
    }

    // 3. Test retrieving all regions
    @Test
    void shouldReturnAllRegions() {
        Village village = new Village("Anand", "388001");
        village.setId(1L);

        Region region1 = new Region(1L, "North Region", village);
        Region region2 = new Region(2L, "South Region", village);

        when(regionRepository.findAll()).thenReturn(List.of(region1, region2));

        List<RegionDTO> result = regionService.getAllRegion();

        assertEquals(2, result.size());
        assertEquals("North Region", result.get(0).getName());
        assertEquals("South Region", result.get(1).getName());
    }

    // 4. Test retrieving a region by ID successfully
    @Test
    void shouldReturnRegionById() {
        Village village = new Village("Anand", "388001");
        village.setId(1L);

        Region region = new Region(5L, "North Region", village);

        when(regionRepository.findById(5L)).thenReturn(Optional.of(region));

        RegionDTO result = regionService.getRegionById(5L);

        assertEquals(5L, result.getId());
        assertEquals("North Region", result.getName());
        assertEquals(1L, result.getVillageId());
    }

    // 5. Test retrieving a region that does not exist
    @Test
    void shouldThrowExceptionWhenRegionDoesNotExist() {
        when(regionRepository.findById(99L)).thenReturn(Optional.empty());

        assertThrows(ErrorException.class,() -> regionService.getRegionById(99L)
        );
    }

    // 6. Test deleting a region
    @Test
    void shouldDeleteRegion() {
        doNothing().when(regionRepository).deleteById(5L);

        regionService.deleteRegion(5L);

        verify(regionRepository).deleteById(5L);
    }
}