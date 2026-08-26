package com.farmer.dto;


public class VillageDTO {

    private Long id;
    private String name;
    private String pinCode;

    public VillageDTO() {
    }

    public VillageDTO(Long id, String name, String pinCode) {
        this.id = id;
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
