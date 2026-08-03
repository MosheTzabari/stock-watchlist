package com.example.stockwatchlist.service;

import java.util.Collection;
import java.util.List;

import org.springframework.stereotype.Service;

import com.example.stockwatchlist.dto.StockDto;
import com.example.stockwatchlist.exception.StockNotFoundException;
import com.example.stockwatchlist.model.Stock;
import com.example.stockwatchlist.repository.StockRepository;

@Service
public class StockService {

    private final StockRepository stockRepository;

    public StockService(StockRepository stockRepository) {
        this.stockRepository = stockRepository;
    }

    public List<StockDto> getAllStocks() {
        return stockRepository.findAllByOrderByTickerAsc().stream().map(this::toDto).toList();
    }

    public StockDto getStock(String ticker) {
        return stockRepository.findByTicker(ticker)
                .map(this::toDto)
                .orElseThrow(() -> new StockNotFoundException(ticker));
    }

    public List<StockDto> getStocks(Collection<String> tickers) {
        if (tickers.isEmpty()) {
            return List.of();
        }
        return stockRepository.findByTickerInOrderByTickerAsc(tickers).stream()
                .map(this::toDto)
                .toList();
    }

    private StockDto toDto(Stock stock) {
        return new StockDto(stock.getTicker(), stock.getCompany(), stock.getMarketCap(),
                stock.getPsRatio(), stock.getDailyChange());
    }
}
