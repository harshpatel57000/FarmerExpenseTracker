package com.farmer.Login_page;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity 
@Table(name="user_table")
@Setter
@Getter
@AllArgsConstructor 
@NoArgsConstructor 
public class User {

    @Id
    @GeneratedValue(strategy=GenerationType.IDENTITY)
    private Long id;

    @Column(nullable=false)
    private String userName;

    @Column(nullable=false)
    private String emailId;

    @Column(nullable=false,unique=true)
    private String phoneNumber;

    @Column(nullable=false,unique=true)
    private String password;

}
