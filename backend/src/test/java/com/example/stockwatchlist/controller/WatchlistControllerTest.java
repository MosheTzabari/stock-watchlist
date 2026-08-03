package com.example.stockwatchlist.controller;

import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

import com.example.stockwatchlist.exception.DuplicateWatchlistException;
import com.example.stockwatchlist.exception.StockNotFoundException;
import com.example.stockwatchlist.exception.WatchlistEntryNotFoundException;
import com.example.stockwatchlist.service.WatchlistService;

@WebMvcTest(WatchlistController.class)
class WatchlistControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockitoBean
    private WatchlistService watchlistService;

    @Test
    void returnsApiErrorForUnknownTicker() throws Exception {
        when(watchlistService.add("UNKNOWN")).thenThrow(new StockNotFoundException("UNKNOWN"));

        mockMvc.perform(post("/api/watchlist/UNKNOWN"))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.status").value(404))
                .andExpect(jsonPath("$.code").value("STOCK_NOT_FOUND"))
                .andExpect(jsonPath("$.path").value("/api/watchlist/UNKNOWN"));
    }

    @Test
    void returnsConflictForDuplicateTicker() throws Exception {
        when(watchlistService.add("TEST")).thenThrow(new DuplicateWatchlistException("TEST"));

        mockMvc.perform(post("/api/watchlist/TEST"))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.code").value("WATCHLIST_ENTRY_EXISTS"));
    }

    @Test
    void returnsNotFoundForMissingDelete() throws Exception {
        doThrow(new WatchlistEntryNotFoundException("TEST"))
                .when(watchlistService).remove("TEST");

        mockMvc.perform(delete("/api/watchlist/TEST"))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.code").value("WATCHLIST_ENTRY_NOT_FOUND"));
    }

    @Test
    void returnsBadRequestForInvalidTicker() throws Exception {
        mockMvc.perform(post("/api/watchlist/INVALID_TICKER"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("VALIDATION_ERROR"));
    }
}
