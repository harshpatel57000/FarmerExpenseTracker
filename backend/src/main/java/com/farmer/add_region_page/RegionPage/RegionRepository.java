package com.farmer.add_region_page.RegionPage;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

public interface RegionRepository extends JpaRepository<Region,Long>{

    List<Region> findAllByUserId(Long userId);

   Optional<Region> findByIdAndUserId(Long id, Long userId);
  

}
