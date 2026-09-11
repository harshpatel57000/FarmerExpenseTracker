package com.farmer.Login_page.UserDTO;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

@Setter 
@Getter 
@AllArgsConstructor 
public class signUpRequest {

    private String userName;

    private String emailId;

    private String phoneNumber;

    private String password;

}
