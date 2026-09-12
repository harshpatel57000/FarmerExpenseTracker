package com.farmer.exception;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.web.bind.*;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.method.annotation.MethodArgumentTypeMismatchException;

@RestControllerAdvice
public class GlobleExceptionHandler {
    @ExceptionHandler(ErrorException.class)
    public ResponseEntity<ErrorResponse> handlerErrorException(ErrorException ex) {

    ErrorResponse errorResponse = new ErrorResponse(ex.getStatus().value(),ex.getMessage(),LocalDateTime.now());
    return ResponseEntity.status(ex.getStatus()).body(errorResponse);
    }

    @ExceptionHandler(MethodArgumentTypeMismatchException.class)
    public ResponseEntity<ErrorResponse> handleTypeMismatch(MethodArgumentTypeMismatchException ex){
        String message="invalid value :"+ ex.getValue();
        ErrorResponse errorResponse=new ErrorResponse(HttpStatus.BAD_REQUEST.value(),message,LocalDateTime.now());
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(errorResponse);
    }
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ErrorResponse>handleValidationException(
        MethodArgumentNotValidException exception){

        List<String> message = exception.getBindingResult().getFieldErrors().stream().map(error ->error.getDefaultMessage()).toList();

            ErrorResponse errorResponse = new ErrorResponse(HttpStatus.BAD_REQUEST.value(),message,LocalDateTime.now());

        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(errorResponse);
    }

    @ExceptionHandler(DataIntegrityViolationException.class)
    public ResponseEntity<String> handleDataIntegrityException(DataIntegrityViolationException ex){
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Data error : invalid or missing data");
    }

    @ExceptionHandler(MissingPathVariableException.class)
    public ResponseEntity<String> handlerMissingPathVariable(MissingPathVariableException ex){
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("missing path variable :"+ex.getVariableName());

    }
    @ExceptionHandler(MissingServletRequestParameterException.class)
    public ResponseEntity<String> handlerMissingParameter(MissingServletRequestParameterException ex){
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("missing request parameter :"+ex.getParameterName());
    }

    @ExceptionHandler(HttpMessageNotReadableException.class)
    public ResponseEntity<String> handlerMessageNotReadable(HttpMessageNotReadableException ex){
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("invalid request body");
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<String> handlerGenericException(Exception ex){
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Something went wrong");
    }

}