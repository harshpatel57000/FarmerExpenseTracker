package com.farmer.Login_page;

import org.springframework.stereotype.Service;

import com.farmer.Login_page.UserDTO.signUpRequest;

import lombok.AllArgsConstructor;

@AllArgsConstructor 
@Service
public class UserService {
    
    private final UserRepository userRepository;

    public User findByEmail(String emailId){
        return userRepository.findByEmailId(emailId).orElse(null);

    }

    public User findByPhoneNumber(String phoneNumber){
        return userRepository.findByPhoneNumber(phoneNumber).orElse(null);
    }

    public User signUp(signUpRequest sign){
        User user=new User();
        user.setUserName(sign.getUserName());
        user.setEmailId(sign.getEmailId());
        user.setPhoneNumber(sign.getPhoneNumber());
        user.setPassword(sign.getPassword());
        return userRepository.save(user);

    }
}
