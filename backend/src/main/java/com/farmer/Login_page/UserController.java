package com.farmer.Login_page;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.farmer.Login_page.UserDTO.*;

import jakarta.validation.Valid;
import lombok.AllArgsConstructor;

import com.farmer.Login_page.UserService;
import com.farmer.Login_page.OTP.loginRequestOTP;
import com.farmer.Login_page.OTP.verifyOTP;



@AllArgsConstructor 
@RestController 
@RequestMapping("/api/auth")
public class UserController {

    private final UserService userService;
    
    @PostMapping("/login")
    public loginResponse loginRequest(@Valid @RequestBody loginRequestPW request){
        return userService.login(request);

    }

    

    @PostMapping("/signup")
    public ResponseEntity<String> signUp(@Valid @RequestBody signupRequest sign){
        userService.signUp(sign);
        return ResponseEntity.ok("User signed up successfully");
    }


    //-------------OTP REQUEST-----------//
    @PostMapping("/loginOtp")
    public ResponseEntity<String> requestOTP(@Valid @RequestBody loginRequestOTP email){
            userService.requestOTP(email);
        return ResponseEntity.ok("OTP sent successfully");
    }

    @PostMapping("/verifyLoginOtp")
    public loginResponse verifyLoginOtp(@Valid @RequestBody verifyOTP request){
        return userService.verifyLoginOtp(request);
    }


    @PostMapping("/verifySignupOtp")
    public ResponseEntity<loginResponse> verifySignupOtp(@Valid @RequestBody verifyOTP request){
        loginResponse response = userService.verifySignupOtp(request);
        return ResponseEntity.ok(response);
    }
}
