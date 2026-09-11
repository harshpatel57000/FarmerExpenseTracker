package com.farmer.Login_page;

import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.farmer.Login_page.UserDTO.loginRequest;
import com.farmer.Login_page.UserDTO.signUpRequest;

import lombok.AllArgsConstructor;

import com.farmer.Login_page.UserService;



 @AllArgsConstructor 
@RestController 
@RequestMapping("/api")
public class UserController {

    private final UserService userService;
    
    @PostMapping("/login")
    public String loginRequest(@RequestBody loginRequest request){

    if(request.getEmailId() != null){

     User user=userService.findByEmail(request.getEmailId());

     if(user == null) return "user not found";

     return "User is Found";
    }

    if(request.getPhoneNumber() != null){

        User user=userService.findByPhoneNumber(request.getPhoneNumber());

        if(user == null) return "user not Found";

        return "User is Found";
    }

        return "invalid request data";
    }

    @PostMapping("/signup")
    public String signUp(@RequestBody signUpRequest sign){
        userService.signUp(sign);
        return "signup completed";
    }
    
}
