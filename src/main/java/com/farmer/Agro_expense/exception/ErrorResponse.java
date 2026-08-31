package com.farmer.Agro_expense.exception;

import java.time.LocalDateTime;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

@AllArgsConstructor
@Getter
@Setter
public class ErrorResponse {


    private int status;
    private String message;
    private LocalDateTime dateTime;
    

}
