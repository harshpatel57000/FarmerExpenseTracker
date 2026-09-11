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
    private String emailId;

    private String phoneNumber;

    @NotBlank(message = "Please,Enter Password!")
    private String password;
}
