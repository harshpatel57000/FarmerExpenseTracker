
package com.farmer.add_region_page;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.data.jpa.test.autoconfigure.DataJpaTest;

import com.farmer.add_region_page.VillagePage.Village;
import com.farmer.add_region_page.VillagePage.VillageRepository;

import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;

@DataJpaTest
class VillageRepositoryTest {

    @Autowired
    private VillageRepository villageRepository;

    @Test
    void shouldSaveAndFindVillageById() {

        // Arrange
        Village village = new Village("Anand", "388001");

        // Act
        Village savedVillage = villageRepository.save(village);

        Optional<Village> result = villageRepository.findById(savedVillage.getId());

        // Assert
        assertTrue(result.isPresent());
        assertEquals("Anand", result.get().getName());
        assertEquals("388001", result.get().getPinCode());
    }

    @Test
    void shouldFindVillageByNameAndPinCode() {

        // Arrange
        Village village = new Village("Anand", "388001");
        villageRepository.save(village);

        // Act
        Optional<Village> result = villageRepository.findByNameAndPinCode("Anand", "388001");

        // Assert
        assertTrue(result.isPresent());
        assertEquals("Anand", result.get().getName());
        assertEquals("388001", result.get().getPinCode());
    }

    @Test
    void shouldReturnEmptyWhenVillageDoesNotExist() {

        // Act
        Optional<Village> result = villageRepository.findByNameAndPinCode("UnknownVillage", "000000");

        // Assert
        assertTrue(result.isEmpty());
    }

    @Test
    void shouldFindAllVillages() {

        // Arrange
        villageRepository.save(new Village("Anand", "388001"));
        villageRepository.save(new Village("Nadiad", "387001"));

        // Act
        var result = villageRepository.findAll();

        // Assert
        assertEquals(2, result.size());
    }

    @Test
    void shouldDeleteVillage() {

        // Arrange
        Village village = villageRepository.save(new Village("Anand", "388001"));
        Long villageId = village.getId();

        // Act
        villageRepository.deleteById(villageId);

        // Assert
        assertFalse(villageRepository.findById(villageId).isPresent());
    }
}
