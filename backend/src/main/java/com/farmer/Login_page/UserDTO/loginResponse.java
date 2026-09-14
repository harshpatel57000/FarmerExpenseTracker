package com.farmer.Login_page.UserDTO;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@AllArgsConstructor
public class loginResponse {

    private Long id;
    private String userName;
    private String emailId;
    private String phoneNumber;
    private String token;
}