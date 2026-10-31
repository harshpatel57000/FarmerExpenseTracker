
package com.farmer.Login_page;

import java.security.SecureRandom;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.farmer.Login_page.OTP.*;
import com.farmer.Login_page.UserDTO.*;
import com.farmer.Login_page.jwt_token.JwtService;
import com.farmer.Login_page.refreshToken.RefreshToken;
import com.farmer.Login_page.refreshToken.RefreshTokenService;
import com.farmer.add_region_page.VillagePage.Village;
import com.farmer.exception.ErrorException;

import lombok.RequiredArgsConstructor;

@RequiredArgsConstructor
@Service
public class UserService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final EmailService emailService;
    private final RefreshTokenService refreshTokenService;

    private final Map<String, otpData> loginOtpStore =
            new ConcurrentHashMap<>();

    private final Map<String, otpData> signOtpStore =
            new ConcurrentHashMap<>();

    private final SecureRandom secureRandom = new SecureRandom();

    //---------------------- SIGNUP USER ----------------------//
    public void signUp(signupRequest sign) {

        if (userRepository.findByEmailId(sign.getEmailId()).isPresent()) {
            throw new ErrorException("Email Id Already Exit");
        }

        if (userRepository.findByPhoneNumber(sign.getPhoneNumber()).isPresent()) {
            throw new ErrorException("PhoneNumber Already Exit");
        }

        String otp = generateOtp();
        String passwordHash = passwordEncoder.encode(sign.getPassword());
        long expiryTime = System.currentTimeMillis() + (10 * 60 * 1000);

        signOtpStore.put(
                sign.getEmailId(),
                new otpData(
                        otp,
                        expiryTime,
                        sign.getUserName(),
                        sign.getEmailId(),
                        sign.getPhoneNumber(),
                        passwordHash
                )
        );

        emailService.sendOtp(sign.getEmailId(), otp);
    }

    //---------------------- VERIFY SIGNUP OTP ----------------------//
    @Transactional
    public loginResponse verifySignupOtp(verifyOTP request) {

        otpData data = signOtpStore.get(request.getEmailId());

        if (data == null) {
            throw new ErrorException(
                    "Signup OTP not found!", HttpStatus.UNAUTHORIZED);
        }

        if (System.currentTimeMillis() > data.getExpiryTime()) {
            signOtpStore.remove(request.getEmailId());
            throw new ErrorException(
                    "OTP expired!", HttpStatus.UNAUTHORIZED);
        }

        if (!data.getOtp().equals(request.getOtp())) {
            throw new ErrorException(
                    "Invalid OTP!", HttpStatus.UNAUTHORIZED);
        }

        User user = new User();
        user.setUserName(data.getUserName());
        user.setEmailId(data.getEmailId());
        user.setPhoneNumber(data.getPhoneNumber());
        user.setPassword(data.getPasswordHash());

        User savedUser = userRepository.save(user);
        signOtpStore.remove(request.getEmailId());

        return createLoginResponse(savedUser);
    }

    //---------------------- CHECK PASSWORD ----------------------//
    public boolean checkPassword(String rawPassword, String storedPassword) {
        return passwordEncoder.matches(rawPassword, storedPassword);
    }

    //---------------------- PASSWORD LOGIN ----------------------//
    @Transactional
    public loginResponse login(loginRequestPW request) {

        User user;

        if (request.getEmailId() != null
                && !request.getEmailId().isBlank()) {

            user = userRepository
                    .findByEmailId(request.getEmailId())
                    .orElse(null);

        } else if (request.getPhoneNumber() != null
                && !request.getPhoneNumber().isBlank()) {

            user = userRepository
                    .findByPhoneNumber(request.getPhoneNumber())
                    .orElse(null);

        } else {
            throw new ErrorException("Email and PhoneNumber is required");
        }

        if (user == null) {
            throw new ErrorException(
                    "user not Found!", HttpStatus.UNAUTHORIZED);
        }

        if (!checkPassword(request.getPassword(), user.getPassword())) {
            throw new ErrorException(
                    "Invalid Password!", HttpStatus.UNAUTHORIZED);
        }

        return createLoginResponse(user);
    }

    //---------------------- REQUEST LOGIN OTP ----------------------//
    public void requestOTP(loginRequestOTP request) {

        User user = userRepository
                .findByEmailId(request.getEmailId())
                .orElseThrow(() -> new ErrorException(
                        "user not found!", HttpStatus.NOT_FOUND));

        String otp = generateOtp();
        long expiryTime = System.currentTimeMillis() + (10 * 60 * 1000);

        loginOtpStore.put(
                request.getEmailId(),
                new otpData(otp, expiryTime)
        );

        emailService.sendOtp(request.getEmailId(), otp);
    }

    private String generateOtp() {
        int otp = 100000 + secureRandom.nextInt(900000);
        return String.valueOf(otp);
    }

    //---------------------- VERIFY LOGIN OTP ----------------------//
    @Transactional
    public loginResponse verifyLoginOtp(verifyOTP request) {

        otpData data = loginOtpStore.get(request.getEmailId());

        if (data == null) {
            throw new ErrorException(
                    "OTP NOT FOUND!", HttpStatus.UNAUTHORIZED);
        }

        if (System.currentTimeMillis() > data.getExpiryTime()) {
            loginOtpStore.remove(request.getEmailId());
            throw new ErrorException(
                    "otp expired!", HttpStatus.UNAUTHORIZED);
        }

        if (!data.getOtp().equals(request.getOtp())) {
            throw new ErrorException(
                    "Invalid OTP!", HttpStatus.UNAUTHORIZED);
        }

        User user = userRepository
                .findByEmailId(request.getEmailId())
                .orElseThrow(() -> new ErrorException(
                        "user not found!", HttpStatus.NOT_FOUND));

        loginOtpStore.remove(request.getEmailId());

        return createLoginResponse(user);
    }

    //---------------------- CREATE BOTH TOKENS ----------------------//
    private loginResponse createLoginResponse(User user) {

        String accessToken = jwtService.generateToken(
                user.getId(), user.getEmailId());

        String refreshToken =
                refreshTokenService.createRefreshToken(user);

        return new loginResponse(
                user.getId(),
                user.getUserName(),
                user.getEmailId(),
                user.getPhoneNumber(),
                accessToken,
                refreshToken
        );
    }

    //---------------------- REFRESH ACCESS TOKEN ----------------------//
@Transactional
public loginResponse refreshAccessToken(String rawRefreshToken) {

    // Validate the refresh token and check expiry/revocation.
    RefreshToken storedToken =
            refreshTokenService.validateRefreshToken(rawRefreshToken);

    // Get the user associated with this refresh token.
    User user = storedToken.getUser();

    // Revoke the old refresh token and generate a new one.
    String newRefreshToken =
            refreshTokenService.rotateRefreshToken(rawRefreshToken);

    // Generate a new access JWT.
    String newAccessToken = jwtService.generateToken(
            user.getId(),
            user.getEmailId()
    );

    // Return the new access token and rotated refresh token.
    return new loginResponse(
            user.getId(),
            user.getUserName(),
            user.getEmailId(),
            user.getPhoneNumber(),
            newAccessToken,
            newRefreshToken
    );
}

//---------------------- LOGOUT ----------------------//
@Transactional
public void logout(String rawRefreshToken) {
    refreshTokenService.revokeRefreshToken(rawRefreshToken);
}


@Transactional(readOnly = true)
public profileDTO getMyProfile() {

    Authentication authentication =
            SecurityContextHolder.getContext().getAuthentication();

    if (authentication == null
            || !authentication.isAuthenticated()
            || authentication.getName() == null
            || authentication.getName().equals("anonymousUser")) {
        throw new org.springframework.security.access.AccessDeniedException(
                "Authentication required");
    }

    String email = authentication.getName();

    User user = userRepository.findByEmailId(email)
            .orElseThrow(() -> new IllegalArgumentException(
                    "User not found"));

    List<String> villageNames = user.getVillages()
            .stream()
            .map(Village::getName)
            .toList();

    return new profileDTO(
            user.getId(),
            user.getUserName(),
            user.getEmailId(),
            user.getPhoneNumber(),
            villageNames
    );
}

@Transactional
public profileDTO updateMyProfile(
        String userName,
        String phoneNumber) {

    Authentication authentication =
            SecurityContextHolder.getContext().getAuthentication();

    if (authentication == null
            || !authentication.isAuthenticated()
            || authentication.getName() == null
            || authentication.getName().equals("anonymousUser")) {
        throw new org.springframework.security.access.AccessDeniedException(
                "Authentication required");
    }

    String email = authentication.getName();

    User user = userRepository.findByEmailId(email)
            .orElseThrow(() -> new IllegalArgumentException(
                    "User not found"));

    if (userName == null || userName.isBlank()) {
        throw new IllegalArgumentException("Name is required");
    }

    if (phoneNumber == null
            || !phoneNumber.matches("[0-9]{10}")) {
        throw new IllegalArgumentException(
                "Enter a valid 10-digit mobile number");
    }

    userRepository.findByPhoneNumber(phoneNumber)
            .filter(existingUser ->
                    !existingUser.getId().equals(user.getId()))
            .ifPresent(existingUser -> {
                throw new IllegalArgumentException(
                        "Mobile number is already registered");
            });

    user.setUserName(userName.trim());
    user.setPhoneNumber(phoneNumber);

    User savedUser = userRepository.save(user);

    List<String> villageNames = savedUser.getVillages()
            .stream()
            .map(Village::getName)
            .toList();

    return new profileDTO(
            savedUser.getId(),
            savedUser.getUserName(),
            savedUser.getEmailId(),
            savedUser.getPhoneNumber(),
            villageNames
    );
}
}


