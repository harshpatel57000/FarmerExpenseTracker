package com.farmer.Login_page.UserDTO;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

@Setter 
@Getter 
@AllArgsConstructor 
public class signupRequest {

    @NotBlank(message="Please,Enter Name!")
    private String userName;

    @NotBlank(message="Please,Enter EmailId!")
    private String emailId;

    @NotBlank(message="Please,Enter PhoneNumber!")
    private String phoneNumber;

    @NotBlank(message="Please,Enter Password!")
    private String password;

}
