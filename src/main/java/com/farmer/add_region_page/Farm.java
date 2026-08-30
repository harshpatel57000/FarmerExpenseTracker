package com.farmer.add_region_page;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@AllArgsConstructor
@NoArgsConstructor
@Data
@Entity
@Table(name="farms")

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
