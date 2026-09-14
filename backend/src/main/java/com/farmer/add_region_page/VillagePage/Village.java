package com.farmer.add_region_page.VillagePage;


import com.farmer.Login_page.User;

import jakarta.persistence.*;


@Entity
@Table(name = "villages")
public class Village {


    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name="user_Id",nullable=false)
    private User user;

    private String name;

    @Column(name = "pin_code", unique = true, nullable = false)
    private String pinCode;

    //jpa
    public Village() {
    }

    //mapper
    public Village(User user,String name, String pinCode) {
        this.user=user;
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
    public Long getUserId(){
        return user.getId();
    }
}