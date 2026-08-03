package com.example.stockwatchlist.model;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

@Document(collection = "watchlist")
public class WatchlistEntry {

    @Id
    private String id;
    private String ticker;

    public WatchlistEntry() {
    }

    public WatchlistEntry(String ticker) {
        this.ticker = ticker;
    }

    public String getId() { return id; }
    public String getTicker() { return ticker; }
}
