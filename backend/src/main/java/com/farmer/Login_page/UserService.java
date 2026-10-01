package com.farmer.Login_page;

import java.security.SecureRandom;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import com.farmer.Login_page.UserDTO.loginRequestPW;
import com.farmer.Login_page.OTP.*;
import com.farmer.Login_page.UserDTO.loginResponse;
import com.farmer.Login_page.UserDTO.signupRequest;
import com.farmer.Login_page.jwt_token.JwtService;
import com.farmer.exception.ErrorException;

import lombok.AllArgsConstructor;

@AllArgsConstructor
@Service
public class UserService {
    
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final EmailService emailService;


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


    //CHECK PASSWORD


    public boolean checkPassword(String rawPassword,String storedPassword){
        return passwordEncoder.matches(rawPassword,storedPassword);
    }




    //LOGIN USER - THROUGH PASSWORD//
    public loginResponse login(loginRequestPW request){

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


    



    //OTP SECTORE [LOGIN THROUGH OTP]
    
    private final Map<String,otpData> otpStore=new ConcurrentHashMap<>();

    //------------------------------------------------------------------//
    public void requestOTP(loginRequestOTP request){
        User user=userRepository.findByEmailId(request.getEmailId()).orElseThrow(()->new ErrorException("user not found!",HttpStatus.NOT_FOUND));

        String otp=generateOtp();

        long expiryTime =System.currentTimeMillis()+(10 * 60* 1000);

otpStore.put(request.getEmailId(),new otpData(otp, expiryTime));

    System.out.println("================================");
    System.out.println("GENERATED OTP = " + otp);
    System.out.println("STORED OTP = " +
        otpStore.get(request.getEmailId()).getOtp());
    System.out.println("MAP SIZE = " + otpStore.size());
    System.out.println("================================");

        emailService.sendOtp(request.getEmailId(),otp);
    }

    private final SecureRandom secureRandom =new SecureRandom();

    private String generateOtp(){
        int otp =100000 +secureRandom.nextInt(900000);
        return String.valueOf(otp);
    }


    //-----------------------------------------------------------------//
     public loginResponse verifyOTP(verifyOTP request){

    System.out.println("================================");
System.out.println("VERIFY EMAIL = " + request.getEmailId());

otpData data = otpStore.get(request.getEmailId());

System.out.println("STORED OTP = " +
        (data == null ? "NULL" : data.getOtp()));

System.out.println("ENTERED OTP = " + request.getOtp());
System.out.println("MAP SIZE = " + otpStore.size());
System.out.println("================================");

        if(data == null){
            throw new ErrorException("OTP NOT FOUND!",HttpStatus.UNAUTHORIZED);
        }

        if(System.currentTimeMillis()>data.getExpiryTime()){
            otpStore.remove(request.getEmailId());

            throw new ErrorException("otp expired!",HttpStatus.UNAUTHORIZED);
        }


        if(!data.getOtp().equals(request.getOtp())){
            throw new ErrorException("Invalid OTP!",HttpStatus.UNAUTHORIZED);
        }


        User user =userRepository.findByEmailId(request.getEmailId()).orElseThrow(()->new ErrorException("user not found!",HttpStatus.NOT_FOUND));

        otpStore.remove(request.getEmailId());

        String token=jwtService.generateToken(user.getId(),user.getEmailId());

        return new loginResponse(user.getId(),user.getUserName(),user.getEmailId(),user.getPhoneNumber(),token);
    }

}

