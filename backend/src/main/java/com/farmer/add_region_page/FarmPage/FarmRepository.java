package com.farmer.add_region_page.FarmPage;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;


public interface FarmRepository extends JpaRepository<Farm,Long> {

    Optional<Farm> findByIdAndUserId(Long id,Long UserId);

    List<Farm> findAllByUserId(Long userId);
}
