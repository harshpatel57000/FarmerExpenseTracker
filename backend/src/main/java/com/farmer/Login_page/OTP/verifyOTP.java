package com.farmer.Login_page.OTP;

import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
@Getter 
public class verifyOTP {

    @NotBlank(message = "please,Enter phone number!")
    private String emailId;

    @NotBlank(message="please,Enter OTP!")
    private String otp;
}
