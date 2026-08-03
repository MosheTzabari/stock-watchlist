package com.example.stockwatchlist.dto;

public record StockDto(
        String ticker,
        String company,
        String marketCap,
        Double psRatio,
        String dailyChange) {
}
