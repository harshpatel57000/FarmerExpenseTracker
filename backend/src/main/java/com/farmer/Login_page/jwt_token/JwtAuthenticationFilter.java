package com.farmer.Login_page.jwt_token;

import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.AllArgsConstructor;

import org.springframework.web.filter.OncePerRequestFilter;

 
import java.io.IOException;
import java.util.Collection;
import java.util.Collections;


@AllArgsConstructor 
@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter {
    
    private JwtService jwtService;

    @Override
    protected void doFilterInternal(
            HttpServletRequest request,
            HttpServletResponse response,
            FilterChain filterChain)
            throws ServletException, IOException {

        String authHeader = request.getHeader("Authorization");

        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            filterChain.doFilter(request, response);
            return;
        }

        String jwt = authHeader.substring(7);

        if (!jwtService.isTokenValid(jwt)) {
             filterChain.doFilter(request, response);
             return;
        }
        
        String username=jwtService.extractUsername(jwt);

        UsernamePasswordAuthenticationToken authenticationName=new UsernamePasswordAuthenticationToken(username,null,Collections.emptyList());

        SecurityContextHolder.getContext().setAuthentication(authenticationName);



        filterChain.doFilter(request, response);
    }
}