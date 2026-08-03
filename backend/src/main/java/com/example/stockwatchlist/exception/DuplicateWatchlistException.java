package com.example.stockwatchlist.exception;

public class DuplicateWatchlistException extends RuntimeException {

    public DuplicateWatchlistException(String ticker) {
        super("Stock '" + ticker + "' is already in the watchlist");
    }
}
