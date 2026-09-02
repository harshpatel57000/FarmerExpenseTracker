package com.farmer.Agro_expense.exception;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice
public class GlobleExceptionHandler {
    @ExceptionHandler(AgroException.class)
    public ResponseEntity<String> handlerAgroException(AgroException ex){
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(ex.getMessage());
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ErrorResponse>handleValidationException(
        MethodArgumentNotValidException exception){

        List<String> message = exception.getBindingResult()
            .getFieldErrors().stream().map(error ->error.getDefaultMessage()).toList();

            ErrorResponse errorResponse = new ErrorResponse(
            HttpStatus.BAD_REQUEST.value(),message,LocalDateTime.now());

         return ResponseEntity
            .status(HttpStatus.BAD_REQUEST)
            .body(errorResponse);
}

}
