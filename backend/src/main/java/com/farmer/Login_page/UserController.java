
package com.farmer.Login_page;

import com.farmer.Login_page.OTP.loginRequestOTP;
import com.farmer.Login_page.OTP.verifyOTP;
import com.farmer.Login_page.UserDTO.loginRequestPW;
import com.farmer.Login_page.UserDTO.signupRequest;
import com.farmer.Login_page.UserDTO.loginResponse;
import com.farmer.Login_page.UserDTO.profileDTO;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import lombok.AllArgsConstructor;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@AllArgsConstructor
@RestController
@RequestMapping("/api/auth")
public class UserController {

    private final UserService userService;

    @PostMapping("/login")
    public loginResponse loginRequest(
            @Valid @RequestBody loginRequestPW request) {
        return userService.login(request);
    }

    @PostMapping("/signup")
    public ResponseEntity<String> signUp(
            @Valid @RequestBody signupRequest sign) {
        userService.signUp(sign);
        return ResponseEntity.ok("User signed up successfully");
    }

    @PostMapping("/loginOtp")
    public ResponseEntity<String> requestOTP(
            @Valid @RequestBody loginRequestOTP email) {
        userService.requestOTP(email);
        return ResponseEntity.ok("OTP sent successfully");
    }

    @PostMapping("/verifyLoginOtp")
    public loginResponse verifyLoginOtp(
            @Valid @RequestBody verifyOTP request) {
        return userService.verifyLoginOtp(request);
    }

    @PostMapping("/verifySignupOtp")
    public ResponseEntity<loginResponse> verifySignupOtp(
            @Valid @RequestBody verifyOTP request) {
        loginResponse response = userService.verifySignupOtp(request);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/refresh")
    public loginResponse refreshToken(
            @RequestBody RefreshTokenRequest request) {
        return userService.refreshAccessToken(request.refreshToken());
    }

    @PostMapping("/logout")
    public ResponseEntity<String> logout(
            @RequestBody RefreshTokenRequest request) {
        userService.logout(request.refreshToken());
        return ResponseEntity.ok("Logged out successfully");
    }

    public record RefreshTokenRequest(String refreshToken) {
    }

    @GetMapping("/profile")
    public profileDTO getMyProfile() {
        return userService.getMyProfile();
    }

    @PutMapping("/profile")
    public profileDTO updateMyProfile(
            @Valid @RequestBody UpdateProfileRequest request) {

        return userService.updateMyProfile(
                request.userName(),
                request.phoneNumber()
        );
    }

    public record UpdateProfileRequest(
            @NotBlank(message = "Name is required")
            String userName,

            @NotBlank(message = "Mobile number is required")
            @Pattern(
                regexp = "[0-9]{10}",
                message = "Enter a valid 10-digit mobile number"
            )
            String phoneNumber
    ) {
    }
}
