package com.farmer.Login_page.OTP;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

@AllArgsConstructor
@Getter
@Setter
public class otpData {

    // OTP
    private String otp;

    // OTP expiry time
    private long expiryTime;


    // Signup temporary data
    private String userName;
    private String emailId;
    private String phoneNumber;
    private String passwordHash;

    // Existing constructor for LOGIN OTP
    public otpData(String otp, long expiryTime) {
        this.otp = otp;
        this.expiryTime = expiryTime;
    }
}