package com.farmer.add_region_page.VillagePage;


import jakarta.persistence.*;


@Entity
@Table(name = "villages")
public class Village {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;

    @Column(name = "pin_code", unique = true, nullable = false)
    private String pinCode;

    //jpa
    public Village() {
    }

    //mapper
    public Village(String name, String pinCode) {
        this.name = name;
        this.pinCode = pinCode;
    }

    public Long getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public String getPinCode() {
        return pinCode;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public void setName(String name) {
        this.name = name;
    }

    public void setPinCode(String pinCode) {
        this.pinCode = pinCode;
    }
}