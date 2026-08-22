package com.farmer.entity;


import jakarta.persistence.*;

@Entity
@Table(name="villages")
public class Village {
    @Id
    @GeneratedValue(strategy=GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable=false,unique=true)
    private String name;

    public Village(){

    }
    public Village(String name){
        this.name=name;
    }

    public Long getId(){
        return id;
    }

    public String getName(){
        return name;
    }

    public void setName(){
        this.name=name;
    }
    
}
