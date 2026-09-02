package com.farmer.add_region_page.VillagePage;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
public interface VillageRepository extends JpaRepository<Village, Long>{
    // Check village  name already exists
    boolean existsByNameIgnoreCase(String name);

    // Find village by PIN code
    Optional<Village> findByPinCode(String pinCode);

    // Check duplicate PIN code
    boolean existsByPinCode(String pinCode);
}

