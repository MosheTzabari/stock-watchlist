package com.example.stockwatchlist.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.util.List;
import java.util.Optional;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import com.example.stockwatchlist.dto.StockDto;
import com.example.stockwatchlist.exception.DuplicateWatchlistException;
import com.example.stockwatchlist.exception.StockNotFoundException;
import com.example.stockwatchlist.exception.WatchlistEntryNotFoundException;
import com.example.stockwatchlist.model.WatchlistEntry;
import com.example.stockwatchlist.repository.WatchlistRepository;

@ExtendWith(MockitoExtension.class)
class WatchlistServiceTest {

    private static final StockDto STOCK = new StockDto(
            "TEST", "Test Company", "$1B", 2.5, "+1.0%");

    @Mock
    private WatchlistRepository watchlistRepository;

    @Mock
    private StockService stockService;

    private WatchlistService service;

    @BeforeEach
    void setUp() {
        service = new WatchlistService(watchlistRepository, stockService);
    }

    @Test
    void addsExistingTickerAndNormalizesInput() {
        when(stockService.getStock("TEST")).thenReturn(STOCK);
        when(watchlistRepository.existsByTicker("TEST")).thenReturn(false);

        StockDto result = service.add("  test  ");

        assertThat(result).isEqualTo(STOCK);
        verify(watchlistRepository).save(org.mockito.ArgumentMatchers.argThat(
                entry -> entry.getTicker().equals("TEST")));
    }

    @Test
    void rejectsUnknownTicker() {
        when(stockService.getStock("UNKNOWN")).thenThrow(new StockNotFoundException("UNKNOWN"));

        assertThatThrownBy(() -> service.add("unknown"))
                .isInstanceOf(StockNotFoundException.class);
        verify(watchlistRepository, never()).save(org.mockito.ArgumentMatchers.any());
    }

    @Test
    void rejectsDuplicateTicker() {
        when(stockService.getStock("TEST")).thenReturn(STOCK);
        when(watchlistRepository.existsByTicker("TEST")).thenReturn(true);

        assertThatThrownBy(() -> service.add("TEST"))
                .isInstanceOf(DuplicateWatchlistException.class);
        verify(watchlistRepository, never()).save(org.mockito.ArgumentMatchers.any());
    }

    @Test
    void removesExistingTicker() {
        WatchlistEntry entry = new WatchlistEntry("TEST");
        when(watchlistRepository.findByTicker("TEST")).thenReturn(Optional.of(entry));

        service.remove(" test ");

        verify(watchlistRepository).delete(entry);
    }

    @Test
    void rejectsRemovingMissingTicker() {
        when(watchlistRepository.findByTicker("MISSING")).thenReturn(Optional.empty());

        assertThatThrownBy(() -> service.remove("missing"))
                .isInstanceOf(WatchlistEntryNotFoundException.class);
    }

    @Test
    void resolvesWatchlistWithOneBatchRequest() {
        when(watchlistRepository.findAllByOrderByTickerAsc())
                .thenReturn(List.of(new WatchlistEntry("AAA"), new WatchlistEntry("BBB")));
        when(stockService.getStocks(List.of("AAA", "BBB"))).thenReturn(List.of(STOCK));

        assertThat(service.getWatchlist()).containsExactly(STOCK);
        verify(stockService).getStocks(List.of("AAA", "BBB"));
    }
}
