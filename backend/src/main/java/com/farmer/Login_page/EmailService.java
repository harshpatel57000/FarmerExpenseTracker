package com.farmer.Login_page;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClient;

import java.util.Map;

@Service 
public class EmailService {

    @Value("${brevo.api-key}")
    private String apiKey;
    
    @Value("${brevo.sender-email}")
    private String senderEmail;

    private final RestClient restClient;

    public EmailService(){
        this.restClient = RestClient.builder().baseUrl("https://api.brevo.com").build();
    }

    public void sendOtp(String recipientEmail,String otp){
        Map<String,Object> request= Map.of("sender",
                                    Map.of("name","Farmer Expense Tracker",
                                    "email",senderEmail),
                                    "to",new Object[]{Map.of("email",recipientEmail)},
                                    "subject","Farmer Expense Tracker -OTP",
                                    "textContent","Your OTP is :"+otp+"\n\nTHis OTP is valid for 10 minutes.");
        ResponseEntity<Void> response=restClient.post()
                .uri("/v3/smtp/email")
                .header("api-key",apiKey)
                .contentType(MediaType.APPLICATION_JSON)
                .body(request)
                .retrieve()
                .toBodilessEntity();

                System.out.println("Brevo response: " + response);
      }

}
