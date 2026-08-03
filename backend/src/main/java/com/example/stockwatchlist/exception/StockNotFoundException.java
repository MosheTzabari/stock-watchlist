package com.example.stockwatchlist.exception;

public class StockNotFoundException extends RuntimeException {

    public StockNotFoundException(String ticker) {
        super("Stock '" + ticker + "' was not found");
    }
}
