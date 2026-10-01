package com.farmer.Login_page.OTP;
import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

@AllArgsConstructor 
@Setter 
@Getter
public class loginRequestOTP {

    @NotBlank(message ="Pleasse,Enter EmailID!")
    private String emailId;

}
