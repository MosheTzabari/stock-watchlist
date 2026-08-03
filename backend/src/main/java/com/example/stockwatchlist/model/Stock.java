package com.example.stockwatchlist.model;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

@Document(collection = "stocks")
public class Stock {

    @Id
    private String id;
    private String ticker;
    private String company;
    private String marketCap;
    private Double psRatio;
    private String dailyChange;

    public Stock() {
    }

    public String getId() { return id; }
    public String getTicker() { return ticker; }
    public String getCompany() { return company; }
    public String getMarketCap() { return marketCap; }
    public Double getPsRatio() { return psRatio; }
    public String getDailyChange() { return dailyChange; }
}
