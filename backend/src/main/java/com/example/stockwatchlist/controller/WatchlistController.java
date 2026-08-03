package com.example.stockwatchlist.controller;

import java.util.List;

import jakarta.validation.constraints.Pattern;

import org.springframework.http.HttpStatus;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import com.example.stockwatchlist.dto.StockDto;
import com.example.stockwatchlist.service.WatchlistService;

@Validated
@RestController
@RequestMapping("/api/watchlist")
public class WatchlistController {

    private static final String TICKER_PATTERN = "^\\s*[A-Za-z0-9.-]{1,15}\\s*$";
    private static final String TICKER_MESSAGE = "Ticker must contain 1 to 15 letters, numbers, dots, or hyphens";

    private final WatchlistService watchlistService;

    public WatchlistController(WatchlistService watchlistService) {
        this.watchlistService = watchlistService;
    }

    @GetMapping
    public List<StockDto> getWatchlist() {
        return watchlistService.getWatchlist();
    }

    @PostMapping("/{ticker}")
    @ResponseStatus(HttpStatus.CREATED)
    public StockDto add(
            @PathVariable @Pattern(regexp = TICKER_PATTERN, message = TICKER_MESSAGE) String ticker) {
        return watchlistService.add(ticker);
    }

    @DeleteMapping("/{ticker}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void remove(
            @PathVariable @Pattern(regexp = TICKER_PATTERN, message = TICKER_MESSAGE) String ticker) {
        watchlistService.remove(ticker);
    }
}
