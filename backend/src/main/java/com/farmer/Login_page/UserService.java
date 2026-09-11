package com.farmer.Login_page;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import com.farmer.Login_page.UserDTO.signUpRequest;
import com.farmer.exception.ErrorException;

import lombok.AllArgsConstructor;

@AllArgsConstructor 
@Service
public class UserService {
    
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    public User findByEmail(String emailId){
        return userRepository.findByEmailId(emailId).orElse(null);

    }

    public User findByPhoneNumber(String phoneNumber){
        return userRepository.findByPhoneNumber(phoneNumber).orElse(null);
    }

    public User signUp(signUpRequest sign){
        User user=new User();

        if(userRepository.findByEmailId(sign.getEmailId()).isPresent()){

            throw new ErrorException("Email Id Already Exit");
        }

        if(userRepository.findByPhoneNumber(sign.getPhoneNumber()).isPresent()){
            throw new ErrorException("PhoneNumber Already Exit");
        }
        
        user.setUserName(sign.getUserName());
        user.setEmailId(sign.getEmailId());
        user.setPhoneNumber(sign.getPhoneNumber());
        user.setPassword(passwordEncoder.encode(sign.getPassword()));
        return userRepository.save(user);

    }

    public boolean checkPassword(String rawPassword,String storedPassword){
        return passwordEncoder.matches(rawPassword,storedPassword);
    }
}

