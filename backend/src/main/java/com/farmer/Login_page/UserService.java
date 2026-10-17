package com.farmer.Login_page;

import java.security.SecureRandom;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import com.farmer.Login_page.OTP.verifyOTP;

import com.farmer.Login_page.UserDTO.*;
import com.farmer.Login_page.OTP.*;

import com.farmer.Login_page.jwt_token.JwtService;

import com.farmer.exception.ErrorException;

import lombok.RequiredArgsConstructor;


@RequiredArgsConstructor
@Service
public class UserService {
    
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final EmailService emailService;

    //----------------------SIGNUP USER----------------------------//
    public void signUp(signupRequest sign){

        if(userRepository.findByEmailId(sign.getEmailId()).isPresent()){

            throw new ErrorException("Email Id Already Exit");
        }

        if(userRepository.findByPhoneNumber(sign.getPhoneNumber()).isPresent()){
            throw new ErrorException("PhoneNumber Already Exit");
        }

        String otp=generateOtp();

        String passwordHash=passwordEncoder.encode(sign.getPassword());

        long expiryTime =System.currentTimeMillis()+(10 * 60* 1000);


        signOtpStore.put(sign.getEmailId(),new otpData(otp,expiryTime,sign.getUserName(),sign.getEmailId(),sign.getPhoneNumber(),passwordHash));

        emailService.sendOtp(sign.getEmailId(),otp);

    }

    //----------------------VERIFY SIGNUP OTP----------------------------//

    public loginResponse verifySignupOtp(verifyOTP request){

        otpData data=signOtpStore.get(request.getEmailId());

        if(data == null){
            throw new ErrorException("Signup OTP not found!",HttpStatus.UNAUTHORIZED);
        }

        if(System.currentTimeMillis() > data.getExpiryTime()){
            signOtpStore.remove(request.getEmailId());
            throw new ErrorException("OTP expired!",HttpStatus.UNAUTHORIZED);
        }

        if(!data.getOtp().equals(request.getOtp())){
            throw new ErrorException("Invalid OTP!",HttpStatus.UNAUTHORIZED);
        }
        User user = new User();

        user.setUserName(data.getUserName());
        user.setEmailId(data.getEmailId());
        user.setPhoneNumber(data.getPhoneNumber());
        user.setPassword(data.getPasswordHash());

        User savedUser =userRepository.save(user);

        String token =jwtService.generateToken(savedUser.getId(),savedUser.getEmailId());

        return new loginResponse(savedUser.getId(),savedUser.getUserName()
        ,savedUser.getEmailId(),savedUser.getPhoneNumber(),token);


    }

    //----------------------CHECK PASSWORD----------------------------//


    public boolean checkPassword(String rawPassword,String storedPassword){
        return passwordEncoder.matches(rawPassword,storedPassword);
    }




    //----------------------LOGIN USER - THROUGH PASSWORD----------------------//
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


    



    //----------------------OTP SECTORE [LOGIN THROUGH OTP]----------------------//
    
    private final Map<String,otpData> loginOtpStore=new ConcurrentHashMap<>();

    private final Map<String,otpData> signOtpStore=new ConcurrentHashMap<>();


        

    
    
    //-----------------------------REQUEST OTP--------------------------------//
    public void requestOTP(loginRequestOTP request){
        User user=userRepository.findByEmailId(request.getEmailId()).orElseThrow(()->new ErrorException("user not found!",HttpStatus.NOT_FOUND));

        String otp=generateOtp();

        System.out.println("Generated OTP: " + otp); 
        // Log the generated OTP for debugging
        long expiryTime =System.currentTimeMillis()+(10 * 60* 1000);

        loginOtpStore.put(request.getEmailId(),new otpData(otp, expiryTime));

        emailService.sendOtp(request.getEmailId(),otp);
    }

    private final SecureRandom secureRandom =new SecureRandom();

    private String generateOtp(){
        int otp =100000 +secureRandom.nextInt(900000);
        return String.valueOf(otp);
    }


    //-----------------------------VERIFY OTP--------------------------------//
     public loginResponse verifyLoginOtp(verifyOTP request){

    
    otpData data = loginOtpStore.get(request.getEmailId());

    
        if(data == null){
            throw new ErrorException("OTP NOT FOUND!",HttpStatus.UNAUTHORIZED);
        }

        if(System.currentTimeMillis()>data.getExpiryTime()){
            loginOtpStore.remove(request.getEmailId());

            throw new ErrorException("otp expired!",HttpStatus.UNAUTHORIZED);
        }


        if(!data.getOtp().equals(request.getOtp())){
            throw new ErrorException("Invalid OTP!",HttpStatus.UNAUTHORIZED);
        }


        User user =userRepository.findByEmailId(request.getEmailId()).orElseThrow(()->new ErrorException("user not found!",HttpStatus.NOT_FOUND));

        loginOtpStore.remove(request.getEmailId());

        String token=jwtService.generateToken(user.getId(),user.getEmailId());

         System.out.println("Jwt token generate successfully for user");



        return new loginResponse(user.getId(),user.getUserName(),user.getEmailId(),user.getPhoneNumber(),token);
    }

}

