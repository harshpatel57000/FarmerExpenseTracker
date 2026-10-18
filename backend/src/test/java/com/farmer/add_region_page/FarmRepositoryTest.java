package com.farmer.add_region_page;

import com.farmer.add_region_page.FarmPage.Farm;
import com.farmer.add_region_page.FarmPage.FarmRepository;
import com.farmer.add_region_page.RegionPage.Region;
import com.farmer.add_region_page.RegionPage.RegionRepository;
import com.farmer.add_region_page.VillagePage.Village;
import com.farmer.add_region_page.VillagePage.VillageRepository;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.data.jpa.test.autoconfigure.DataJpaTest;

import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;

@DataJpaTest
class FarmRepositoryTest {

    @Autowired
    private FarmRepository farmRepository;

    @Autowired
    private RegionRepository regionRepository;

    @Autowired
    private VillageRepository villageRepository;

    // 1. Save and find farm by ID
    @Test
    void shouldSaveAndFindFarmById() {
        Village village =
                villageRepository.save(new Village("Anand", "388001"));

        Region region =
                regionRepository.save(new Region(null, "North Region", village));

        Farm farm = new Farm(null, "Farm A", 2.5, region);

        Farm savedFarm = farmRepository.save(farm);

        Optional<Farm> result =
                farmRepository.findById(savedFarm.getId());

        assertTrue(result.isPresent());
        assertEquals("Farm A", result.get().getName());
        assertEquals(2.5, result.get().getArea());
        assertEquals(
                region.getId(),
                result.get().getRegion().getId()
        );
    }

    // 2. Find all farms
    @Test
    void shouldFindAllFarms() {
        Village village =
                villageRepository.save(new Village("Anand", "388001"));

        Region region =
                regionRepository.save(new Region(null, "North Region", village));

        farmRepository.save(new Farm(null, "Farm A", 2.5, region));
        farmRepository.save(new Farm(null, "Farm B", 3.0, region));

        List<Farm> result = farmRepository.findAll();

        assertEquals(2, result.size());
    }

    // 3. Farm does not exist
    @Test
    void shouldReturnEmptyWhenFarmDoesNotExist() {
        Optional<Farm> result = farmRepository.findById(999L);

        assertTrue(result.isEmpty());
    }

    // 4. Delete farm
    @Test
    void shouldDeleteFarm() {
        Village village =
                villageRepository.save(new Village("Anand", "388001"));

        Region region =
                regionRepository.save(new Region(null, "North Region", village));

        Farm savedFarm =
                farmRepository.save(new Farm(null, "Farm A", 2.5, region));

        Long farmId = savedFarm.getId();

        farmRepository.deleteById(farmId);
        farmRepository.flush();

        assertFalse(farmRepository.findById(farmId).isPresent());
    }
}