package com.farmer.entity;

import jakarta.persistence.*;
import java.time.LocalDate;
import com.farmer.entity.*;

import lombok.*;
@Setter@Getter@Builder
@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name="cropcycle")
public class CropCycle {
    @Id
    @GeneratedValue(strategy=GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name="farm_id",nullable=false)
    private Farm farm;

    @Column(nullable=false)
    private String cropName;

    @Column(nullable=false)
    private LocalDate startDate;

    @Column(nullable=true)
    private LocalDate endDate;

    @Column(nullable=false)
    private String  status;

    
}
