package com.farmer.Login_page.jwt_token;


import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import javax.crypto.SecretKey;

import java.nio.charset.StandardCharsets;
import java.util.Date;



@Service
public class JwtService {

    @Value("${jwt.secret}")
    private  String secret;

    @Value("${jwt.expiration}")
    private  long expiration;

    private  SecretKey getKey() {
        return Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
    }

    public String generateToken(Long userId, String email) {

        return Jwts.builder()
                .subject(email)
                .claim("userId", userId)
                .issuedAt(new Date())
                .expiration(new Date(System.currentTimeMillis() + expiration))
                .signWith(getKey())
                .compact();
    }


    public  boolean isTokenValid(String jwt) {
    try {
        Jwts.parser()
                .verifyWith(getKey())
                .build()
                .parseSignedClaims(jwt);

        return true;

         } catch (Exception e) {
            return false;
            }
    }
    
    public String extractUsername(String jwt){
        return Jwts.parser().verifyWith(getKey()).build().parseSignedClaims(jwt).getPayload().getSubject();
    }

    public Long extractUserId(String jwt){
        return Jwts.parser().verifyWith(getKey()).build().parseSignedClaims(jwt).getPayload().get("userId",Long.class);
    }

}
