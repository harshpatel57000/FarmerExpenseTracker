package com.farmer.repository;

import com.farmer.entity.Agro;

import org.springframework.data.jpa.repository.JpaRepository;

public interface AgroRepository extends JpaRepository<Agro,Long> {

}
