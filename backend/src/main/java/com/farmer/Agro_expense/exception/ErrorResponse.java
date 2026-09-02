package com.farmer.Agro_expense.exception;

import java.time.LocalDateTime;
import java.util.List;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

@AllArgsConstructor
@Getter
@Setter
public class ErrorResponse {


    private int status;
    private List<String> message;
    private LocalDateTime dateTime;
    

}
