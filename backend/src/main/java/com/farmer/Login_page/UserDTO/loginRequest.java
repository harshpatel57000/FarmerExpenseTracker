package com.farmer.Login_page.UserDTO;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

@AllArgsConstructor 
@Setter 
@Getter 
public class loginRequest {


    @Email 
    @NotBlank
    private String emailId;

    @NotBlank
    private String phoneNumber;

    @NotBlank
    private String password;
}
