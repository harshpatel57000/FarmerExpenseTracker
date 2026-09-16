package com.farmer.Login_page;

import java.util.Set;

import com.farmer.add_region_page.VillagePage.Village;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity 
@Table(name="user_table")
@Setter
@Getter
@AllArgsConstructor 
@NoArgsConstructor 
public class User {

    @Id
    @GeneratedValue(strategy=GenerationType.IDENTITY)
    private Long id;

    @ManyToMany
    @JoinTable(
        name = "user_village",
        joinColumns = @JoinColumn(name = "user_id"),
        inverseJoinColumns = @JoinColumn(name = "village_id"))
    private Set<Village> villages;

    
    @Column(nullable=false)
    private String userName;

    @Column(nullable=false)
    private String emailId;

    @Column(nullable=false,unique=true)
    private String phoneNumber;

    @Column(nullable=false)
    private String password;

}
