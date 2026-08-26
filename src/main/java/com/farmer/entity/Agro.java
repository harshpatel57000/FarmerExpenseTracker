package com.farmer.entity;

import lombok.*;
import jakarta.persistence.*;

import java.time.LocalDate;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name="agro_expense")
public class Agro {
    
    @GeneratedValue(strategy=GenerationType.IDENTITY)
    @Column(nullable=false)
    private Long id;

    @Column(nullable=false)
    private String productName;

    @Column(nullable=false)
    private int BagQuntity;

    @Column(nullable = false)
    private Double bagWeight;


    @Column(nullable=false)
    private Float pricePerBag;

    @Column(nullable=false)
    private Float totalWeight;

    @Column(nullable=false)
    private Float totalAmount;

    @Column(nullable=false)
    private LocalDate purchesDate;

}
