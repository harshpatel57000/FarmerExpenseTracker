package com.farmer.add_region_page.FarmPage;

import com.farmer.Login_page.User;
import com.farmer.add_region_page.RegionPage.Region;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@AllArgsConstructor
@Getter
@Setter 
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

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;
}
