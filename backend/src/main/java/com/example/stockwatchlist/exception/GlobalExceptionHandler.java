package com.example.stockwatchlist.exception;

import java.time.Instant;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.ConstraintViolationException;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.dao.DataAccessResourceFailureException;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import com.example.stockwatchlist.dto.ApiError;

@RestControllerAdvice
public class GlobalExceptionHandler {

    private static final Logger log = LoggerFactory.getLogger(GlobalExceptionHandler.class);

    @ExceptionHandler(ConstraintViolationException.class)
    ResponseEntity<ApiError> handleValidation(ConstraintViolationException exception,
            HttpServletRequest request) {
        String message = exception.getConstraintViolations().stream()
                .findFirst()
                .map(violation -> violation.getMessage())
                .orElse("Invalid request");
        return error(HttpStatus.BAD_REQUEST, "VALIDATION_ERROR", message, request);
    }

    @ExceptionHandler(StockNotFoundException.class)
    ResponseEntity<ApiError> handleStockNotFound(StockNotFoundException exception,
            HttpServletRequest request) {
        return error(HttpStatus.NOT_FOUND, "STOCK_NOT_FOUND", exception.getMessage(), request);
    }

    @ExceptionHandler({DuplicateWatchlistException.class, DuplicateKeyException.class})
    ResponseEntity<ApiError> handleDuplicate(Exception exception, HttpServletRequest request) {
        String message = exception instanceof DuplicateWatchlistException
                ? exception.getMessage()
                : "Stock is already in the watchlist";
        return error(HttpStatus.CONFLICT, "WATCHLIST_ENTRY_EXISTS", message, request);
    }

    @ExceptionHandler(WatchlistEntryNotFoundException.class)
    ResponseEntity<ApiError> handleWatchlistNotFound(WatchlistEntryNotFoundException exception,
            HttpServletRequest request) {
        return error(HttpStatus.NOT_FOUND, "WATCHLIST_ENTRY_NOT_FOUND", exception.getMessage(), request);
    }

    @ExceptionHandler(DataAccessResourceFailureException.class)
    ResponseEntity<ApiError> handleDatabaseUnavailable(DataAccessResourceFailureException exception,
            HttpServletRequest request) {
        log.error("MongoDB is unavailable", exception);
        return error(HttpStatus.SERVICE_UNAVAILABLE, "DATABASE_UNAVAILABLE",
                "The database is currently unavailable", request);
    }

    @ExceptionHandler(Exception.class)
    ResponseEntity<ApiError> handleUnexpected(Exception exception, HttpServletRequest request) {
        log.error("Unexpected request failure", exception);
        return error(HttpStatus.INTERNAL_SERVER_ERROR, "INTERNAL_ERROR",
                "An unexpected error occurred", request);
    }

    private ResponseEntity<ApiError> error(HttpStatus status, String code, String message,
            HttpServletRequest request) {
        ApiError body = new ApiError(Instant.now(), status.value(), code, message, request.getRequestURI());
        return ResponseEntity.status(status).body(body);
    }
}
