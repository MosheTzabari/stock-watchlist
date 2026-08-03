package com.example.stockwatchlist.repository;

import java.util.Collection;
import java.util.List;
import java.util.Optional;

import org.springframework.data.mongodb.repository.MongoRepository;

import com.example.stockwatchlist.model.Stock;

public interface StockRepository extends MongoRepository<Stock, String> {

    Optional<Stock> findByTicker(String ticker);

    List<Stock> findAllByOrderByTickerAsc();

    List<Stock> findByTickerInOrderByTickerAsc(Collection<String> tickers);
}
