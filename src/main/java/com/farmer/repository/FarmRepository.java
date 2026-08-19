package com.farmer.repository;

import com.farmer.entity.Farm;
import org.springframework.data.jpa.repository.JpaRepository;


public interface FarmRepository extends JpaRepository<Farm,Long> {

}
