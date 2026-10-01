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
    public signupResponse signUp(@Valid @RequestBody signupRequest sign){
       User user= userService.signUp(sign);
        return new signupResponse(user);
    }


    //-------------OTP REQUEST-----------//
    @PostMapping("/loginOtp")
    public ResponseEntity<String> requestOTP(@Valid @RequestBody loginRequestOTP email){
            userService.requestOTP(email);
        return ResponseEntity.ok("OTP sent successfully");
    }

    @PostMapping("/verifyOtp")
    public loginResponse verifyOtp(@Valid @RequestBody verifyOTP request){
        return userService.verifyOTP(request);
    }


}
