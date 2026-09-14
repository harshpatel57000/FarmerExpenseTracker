package com.farmer.Login_page;

import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import com.farmer.Login_page.UserDTO.loginRequest;
import com.farmer.Login_page.UserDTO.loginResponse;
import com.farmer.Login_page.UserDTO.signupRequest;
import com.farmer.exception.ErrorException;

import lombok.AllArgsConstructor;

import com.farmer.Login_page.jwt.JwtService;

@AllArgsConstructor 
@Service
public class UserService {
    
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;

    //LOGIN USER//
    public loginResponse login(loginRequest request){

        User user;

        if(request.getEmailId() != null && !request.getEmailId().isBlank()){

            user=userRepository.findByEmailId(request.getEmailId()).orElse(null);
            
                }else if(request.getPhoneNumber() != null && !request.getPhoneNumber().isBlank()){
                      
                    user=userRepository.findByPhoneNumber(request.getPhoneNumber()).orElse(null);
                
                    }else{
                      
                        throw new ErrorException("Email and PhoneNumber is required");
                     
                    }
        if(user == null){
            throw new ErrorException("user not Found!",HttpStatus.UNAUTHORIZED);
        }

        
         if(!checkPassword(request.getPassword(),user.getPassword())){
            throw new ErrorException("Invalid Password!",HttpStatus.UNAUTHORIZED);
         }
        String token = jwtService.generateToken(user.getId(),user.getEmailId());

    return new loginResponse(user.getId(),user.getUserName(),user.getEmailId(),user.getPhoneNumber(),token);

    }   


    //SIGNUP USER//
    public User signUp(signupRequest sign){
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

