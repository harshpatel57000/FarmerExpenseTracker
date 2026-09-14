package com.farmer.add_region_page.VillagePage;

import com.farmer.Login_page.User;

public class VillageDTO {

    private Long id;
    private Long userId;
    private String name;
    private String pinCode;

    public VillageDTO() {
    }

    public VillageDTO(Long id,Long userId, String name, String pinCode) {
        this.id = id;
        this.userId=userId;
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
        return userId;
    }
    public void setUserId(Long userId) {
        this.userId = userId;
    }

}
