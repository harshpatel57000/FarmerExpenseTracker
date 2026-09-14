package com.farmer.Login_page.jwt_token;


import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.stereotype.Service;

import javax.crypto.SecretKey;
import java.util.Date;



@Service
public class JwtService {

        private final String secret = "my-super-secret-key-for-farmer-expense-tracker-2026";

    private final long expiration = 1000 * 60 * 60; // 1 hour

    private  SecretKey getKey() {
        return Keys.hmacShaKeyFor(secret.getBytes());
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
    

}
