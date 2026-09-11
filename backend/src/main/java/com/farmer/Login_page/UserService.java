package com.farmer.Login_page;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import com.farmer.Login_page.UserDTO.loginRequest;
import com.farmer.Login_page.UserDTO.signUpRequest;
import com.farmer.exception.ErrorException;

import lombok.AllArgsConstructor;

@AllArgsConstructor 
@Service
public class UserService {
    
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    public User login(loginRequest request){

        User user;

        if(request.getEmailId() != null && !request.getEmailId().isBlank()){

            user=userRepository.findByEmailId(request.getEmailId()).orElse(null);
            
                }else if(request.getPhoneNumber() != null && !request.getPhoneNumber().isBlank()){
                      
                    user=userRepository.findByPhoneNumber(request.getPhoneNumber()).orElse(null);
                
                    }else{
                      
                        throw new ErrorException("Email and PhoneNumber is required");
                     
                    }
        if(user == null){
            throw new ErrorException("user not Found!");
        }

        
         if(!checkPassword(request.getPassword(),user.getPassword())){
            throw new ErrorException("Invalid Password!");
         }

         return user;

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

