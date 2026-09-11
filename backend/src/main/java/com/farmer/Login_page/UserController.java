package com.farmer.Login_page;

import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.farmer.Login_page.UserDTO.loginRequest;
import com.farmer.Login_page.UserDTO.loginResponse;
import com.farmer.Login_page.UserDTO.signUpRequest;

import jakarta.validation.Valid;
import lombok.AllArgsConstructor;

import com.farmer.Login_page.UserService;



 @AllArgsConstructor 
@RestController 
@RequestMapping("/api")
public class UserController {

    private final UserService userService;
    
    @PostMapping("/login")
    public loginResponse loginRequest(@Valid @RequestBody loginRequest request){
        User user=userService.login(request);

     return new loginResponse(user);
    }

    

    @PostMapping("/signup")
    public String signUp(@Valid @RequestBody signUpRequest sign){
        userService.signUp(sign);
        return "signup completed";
    }

}
