package com.farmer.Agro_expense;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

public interface AgroRepository extends JpaRepository<Agro,Long> {
        List<Agro> findByUserId(Long userId);

        Optional<Agro> findByIdAndUserId(Long id, Long userId);


}
