package com.example.stockwatchlist.service;

import java.util.List;
import java.util.Locale;

import org.springframework.stereotype.Service;

import com.example.stockwatchlist.dto.StockDto;
import com.example.stockwatchlist.exception.DuplicateWatchlistException;
import com.example.stockwatchlist.exception.WatchlistEntryNotFoundException;
import com.example.stockwatchlist.model.WatchlistEntry;
import com.example.stockwatchlist.repository.WatchlistRepository;

@Service
public class WatchlistService {

    private final WatchlistRepository watchlistRepository;
    private final StockService stockService;

    public WatchlistService(WatchlistRepository watchlistRepository, StockService stockService) {
        this.watchlistRepository = watchlistRepository;
        this.stockService = stockService;
    }

    public List<StockDto> getWatchlist() {
        List<String> tickers = watchlistRepository.findAllByOrderByTickerAsc().stream()
                .map(WatchlistEntry::getTicker)
                .toList();
        return stockService.getStocks(tickers);
    }

    public StockDto add(String inputTicker) {
        String ticker = normalize(inputTicker);
        StockDto stock = stockService.getStock(ticker);
        if (watchlistRepository.existsByTicker(ticker)) {
            throw new DuplicateWatchlistException(ticker);
        }
        watchlistRepository.save(new WatchlistEntry(ticker));
        return stock;
    }

    public void remove(String inputTicker) {
        String ticker = normalize(inputTicker);
        WatchlistEntry entry = watchlistRepository.findByTicker(ticker)
                .orElseThrow(() -> new WatchlistEntryNotFoundException(ticker));
        watchlistRepository.delete(entry);
    }

    private String normalize(String ticker) {
        return ticker.trim().toUpperCase(Locale.ROOT);
    }
}
