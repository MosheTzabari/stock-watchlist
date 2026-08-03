package com.example.stockwatchlist.exception;

public class WatchlistEntryNotFoundException extends RuntimeException {

    public WatchlistEntryNotFoundException(String ticker) {
        super("Stock '" + ticker + "' is not in the watchlist");
    }
}
