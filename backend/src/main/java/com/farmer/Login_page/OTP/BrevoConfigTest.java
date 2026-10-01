package com.farmer.Login_page.OTP;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import jakarta.annotation.PostConstruct;


@Component
public class BrevoConfigTest {

    @Value("${brevo.api-key}")
    private String apiKey;

    @PostConstruct
    public void test() {
        System.out.println("Brevo API key loaded: " + (apiKey != null && !apiKey.isBlank()));
    }
}