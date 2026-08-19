package com.farmer.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import com.farmer.entity.Region;

@AllArgsConstructor
@NoArgsConstructor
@Data
@Entity
@Table(name="farmes")

public class Farm {
    @Id
    @GeneratedValue(strategy=GenerationType.IDENTITY)
    private  Long id;

    private String name;

    private Double area;

    @ManyToOne
    @JoinColumn(name="region_id")
    private Region region;
}
