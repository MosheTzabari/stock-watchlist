package com.example.stockwatchlist.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.mongodb.repository.MongoRepository;

import com.example.stockwatchlist.model.WatchlistEntry;

public interface WatchlistRepository extends MongoRepository<WatchlistEntry, String> {

    boolean existsByTicker(String ticker);

    List<WatchlistEntry> findAllByOrderByTickerAsc();

    Optional<WatchlistEntry> findByTicker(String ticker);
}
