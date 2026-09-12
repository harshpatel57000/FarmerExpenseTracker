package com.farmer.exception;

import org.springframework.http.HttpStatus;

public class ErrorException extends RuntimeException {

    public final HttpStatus status;
    public ErrorException(String message){
        super(message);
        this.status=HttpStatus.BAD_REQUEST;
    }

    public ErrorException(String message,HttpStatus status){
        super(message);
        this.status=status;
    }

    public HttpStatus getStatus(){
        return status;
    }


}
