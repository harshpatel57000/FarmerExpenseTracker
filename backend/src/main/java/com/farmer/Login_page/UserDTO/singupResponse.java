package com.farmer.Login_page.UserDTO;

import com.farmer.Login_page.User;

import lombok.Getter;
import lombok.Setter;

@Setter 
@Getter
public  class singupResponse {

    

    private Long id;

    private String userName;

    private String emailId;

    private String phoneNumber;

    public singupResponse(User user) {
        this.id=user.getId();
        this.userName=user.getUserName();
        this.emailId=user.getEmailId();
        this.phoneNumber=user.getPhoneNumber();
    }
}
