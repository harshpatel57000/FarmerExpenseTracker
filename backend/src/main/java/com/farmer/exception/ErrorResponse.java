package com.farmer.exception;

import java.time.LocalDateTime;
import java.util.List;

import lombok.Getter;
import lombok.Setter;


@Getter
@Setter
public class ErrorResponse {


    private int status;
    private Object message;
    private LocalDateTime dateTime;

    public ErrorResponse(int status, String message, LocalDateTime dateTime) {
        this.status = status;
        this.message = message;
        this.dateTime = dateTime;
    }
    public ErrorResponse(int status, List<String> message, LocalDateTime dateTime) {
        this.status = status;
        this.message = message;
        this.dateTime = dateTime;
    }

}
