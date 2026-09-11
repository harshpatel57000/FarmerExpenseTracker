package com.farmer.Login_page;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

public interface UserRepository extends JpaRepository<User,Long> {

    Optional<User> findByEmailId(String emailId);

    Optional<User> findByPhoneNumber(String phoneNumber);

}
