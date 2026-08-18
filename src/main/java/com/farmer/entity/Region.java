package com.farmer.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "regions")
@Data
@NoArgsConstructor
@AllArgsConstructor

public class Region {
    @Id
    @GeneratedValue(strategy=GenerationType.IDENTITY)
     private Long id;

     private String name;

     @ManyToOne
     @JoinColumn(name="village_id")
     private Village village;

}