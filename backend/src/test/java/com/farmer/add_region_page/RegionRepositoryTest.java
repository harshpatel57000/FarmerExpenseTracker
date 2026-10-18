
package com.farmer.add_region_page;

import com.farmer.add_region_page.RegionPage.Region;
import com.farmer.add_region_page.RegionPage.RegionRepository;
import com.farmer.add_region_page.VillagePage.Village;
import com.farmer.add_region_page.VillagePage.VillageRepository;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.data.jpa.test.autoconfigure.DataJpaTest;

import java.util.Optional;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

@DataJpaTest
class RegionRepositoryTest {

    @Autowired
    private RegionRepository regionRepository;

    @Autowired
    private VillageRepository villageRepository;

    // 1. Test saving and finding a region by ID
    @Test
    void shouldSaveAndFindRegionById() {
        Village village =
                villageRepository.save(new Village("Anand", "388001"));

        Region region = new Region(null, "North Region", village);

        Region savedRegion = regionRepository.save(region);

        Optional<Region> result =
                regionRepository.findById(savedRegion.getId());

        assertTrue(result.isPresent());
        assertEquals("North Region", result.get().getName());
        assertEquals(
                village.getId(),
                result.get().getVillage().getId()
        );
    }

    // 2. Test retrieving all regions
    @Test
    void shouldFindAllRegions() {
        Village village =
                villageRepository.save(new Village("Anand", "388001"));

        regionRepository.save(new Region(null, "North Region", village));
        regionRepository.save(new Region(null, "South Region", village));

        List<Region> result = regionRepository.findAll();

        assertEquals(2, result.size());
    }

    // 3. Test when a region does not exist
    @Test
    void shouldReturnEmptyWhenRegionDoesNotExist() {
        Optional<Region> result = regionRepository.findById(999L);

        assertTrue(result.isEmpty());
    }

    // 4. Test deleting a region
    @Test
    void shouldDeleteRegion() {
        Village village =
                villageRepository.save(new Village("Anand", "388001"));

        Region savedRegion = regionRepository.save(
                new Region(null, "North Region", village)
        );

        Long regionId = savedRegion.getId();

        regionRepository.deleteById(regionId);
        regionRepository.flush();

        assertFalse(regionRepository.findById(regionId).isPresent());
    }
}
