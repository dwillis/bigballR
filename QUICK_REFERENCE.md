# bigballR - Quick Reference Guide

## Function Call Stack (High to Low Level)

```
USER APPLICATION
        ↓
┌─────────────────────────────────────────────────────┐
│ HIGH-LEVEL ANALYSIS FUNCTIONS                       │
├─────────────────────────────────────────────────────┤
│ on_off_generator()      → Calculate on/off stats    │
│ get_player_combos()     → Player duo/trio analysis  │
│ get_lineups()           → Aggregate to lineup level │
│ get_player_stats()      → Player game/season stats  │
│ plot_player_stints()    → Visualize game stints     │
│ plot_mins_dist()        → Playing time charts       │
└─────────────────────────────────────────────────────┘
        ↓
┌─────────────────────────────────────────────────────┐
│ MID-LEVEL DATA PROCESSING                          │
├─────────────────────────────────────────────────────┤
│ get_play_by_play()      → Batch PBP processing     │
│ get_box_scores()        → Batch box score fetch    │
│ get_possessions()       → Possession aggregation   │
│ get_team_stats()        → Team aggregates          │
└─────────────────────────────────────────────────────┘
        ↓
┌─────────────────────────────────────────────────────┐
│ LOW-LEVEL SCRAPING FUNCTIONS                       │
├─────────────────────────────────────────────────────┤
│ scrape_game()           → Get single PBP HTML      │
│ scrape_box()            → Get single box HTML      │
│ get_team_schedule()     → Get schedule from team   │
│ get_team_roster()       → Get roster from team     │
│ get_date_games()        → Get games by date/conf   │
└─────────────────────────────────────────────────────┘
        ↓
┌─────────────────────────────────────────────────────┐
│ WEB & DATA PROCESSING LAYER                        │
├─────────────────────────────────────────────────────┤
│ XML::readHTMLTable()    → Parse HTML tables        │
│ stringr/regex           → Extract IDs & names      │
│ dplyr transforms        → Clean & reshape data     │
│ convert_events()        → Normalize event types    │
└─────────────────────────────────────────────────────┘
        ↓
STATS.NCAA.ORG (HTML)
```

## Core Data Flow

```
SCHEDULE RETRIEVAL PHASE:
get_date_games(date, conference)
  ↓
URL: /season_divisions/{seasonid}/scoreboards
  ↓
Parse HTML → Extract game IDs
  ↓
Return: DataFrame with Game_IDs
  ↓
  
PLAY-BY-PLAY RETRIEVAL PHASE:
get_play_by_play(game_ids)
  ↓
For each game_id:
  scrape_game(game_id)
    ↓
    URL: /contests/{game_id}/play_by_play
    ↓
    Parse HTML tables → Detect V1/V2 format
    ↓
    Extract events, players, substitutions
    ↓
    Track on-court 5v5 lineups
  ↓
Bind all games → Return complete PBP
  ↓
  
ANALYSIS PHASE:
get_lineups(pbp_data)
  ↓
Group by unique 5v5 combinations
  ↓
Calculate aggregate stats per lineup
  ↓
Return: Lineup stats with +/- metrics
  ↓
on_off_generator(lineups, player)
  ↓
Filter for specific player
  ↓
Compare with/without that player
  ↓
Return: On/off differential stats
```

## Key Files to Modify

### For Women's Basketball Adaptation

1. **`R/all_functions.R`** (3,528 lines)
   - Lines 55-60: URL patterns (may need gender parameter)
   - Lines 1099-1227: get_date_games() - season IDs hardcoded
   - Lines 1167-1200: Conference ID mappings
   - Lines 1364-1553: get_team_schedule() - team.name matching
   - Lines 1581-1673: get_team_roster() - same structure
   - Lines 3297-3385: scrape_box() - table indices
   
2. **`data/teamids.RData`**
   - Replace with WBB team ID database
   - Need structure: Team, Conference, Season, ID
   
3. **`conference_names`**
   - Verify/update conference mappings
   
4. **`DESCRIPTION`**
   - Update documentation if needed
   
5. **`README.md`**
   - Add WBB examples
   - Document gender parameter

---

## URL Pattern Reference

### Men's Basketball (Current)
```
Play-by-play: https://stats.ncaa.org/contests/{game_id}/play_by_play/
Box scores:   https://stats.ncaa.org/contests/{game_id}/individual_stats
Schedule:     https://stats.ncaa.org/teams/{team_id}
Roster:       https://stats.ncaa.org/teams/{team_id}/roster
Games by date: https://stats.ncaa.org/season_divisions/{season_id}/scoreboards
```

### Women's Basketball (To Be Determined)
- May be identical to above
- May require `/women/` in path
- May use different season_id values
- **ACTION**: Test on actual WBB game URLs

---

## Season ID Reference (Men's)

```R
# From all_functions.R lines 1111-1157
2024-25: 18403
2023-24: 18221
2022-23: 17940
2021-22: 17783
2020-21: 17420
2019-20: 17060
2018-19: 16700
2017-18: 13533
2016-17: 13100
2015-16: 12700
2014-15: 12320
2013-14: 11700
2012-13: 10883
2011-12: 10480
2010-11: 10220
```

**NOTE**: Women's basketball season IDs likely differ

---

## Conference ID Reference

```R
AAC: 823          SWAC: 916
ACC: 821          Big 12: 25354
ASUN: 920         Big East: 30184
Am East: 845      C-USA: 24312
Atlantic 10: 820  Horizon: 881
Big Sky: 825      Ivy: 865
Big South: 826    MAAC: 871
Big Ten: 827      MAC: 875
Big West: 904     MEAC: 876
CAA: 837          Mid-American: 884
MWC: 5486         Pac-12: 905
NEC: 846          Patriot: 838
OVC: 902          SEC: 911
SOCON: 912        Southland: 914
Summit: 819       Sun Belt: 818
WAC: 923          WCC: 922
All: 0
```

---

## HTML Table Structure (scrape_game)

Position in `table <- XML::readHTMLTable(html)`:

```
table[[1]]     → Empty/metadata
table[[2]]     → Half scores (row 1-2 = Away/Home scores, 4 cols if no OT)
table[[3]]     → Empty
table[[4]]     → First Half play-by-play events
table[[5]]     → Second Half play-by-play events
table[[5+i]]   → Overtime i play-by-play events (if applicable)
```

**Current Code Pattern**:
```R
half_scores <- table[[2]][1:2,]
first_half <- table[[4]] %>% mutate(Half_Status = 1)
second_half <- table[[5]] %>% mutate(Half_Status = 2)
# Then process overtimes if ncol(half_scores) > 4
```

---

## Team Name Extraction Pattern

From `get_team_schedule()` lines 1415-1422:
```R
# Current pattern handles:
df$Opponent_with_detail <- df$Opponent |>
  str_remove(" 202.*$")              # Remove season year
  
# Then removes neutral site indicators:
df$Opponent <- df$Opponent_with_detail |>
  str_remove(" \\@[A-Z].*$")         # Remove @ location
  
# Handles rankings: "Ohio State (3)" → "Ohio State"
stringr::str_extract(x, "(?<=[\\#[0-9]+] ).*")
```

---

## Player Name Normalization

Used in multiple functions (lines 217-220, 3361-3367, etc.):
```R
# Input: "John Smith Jr." or "SMITH,JOHN"
# Step 1: Remove non-alphanumeric except spaces
format <- gsub("[^[:alnum:] ]", "", clean_name)

# Step 2: Convert to FIRST.LAST uppercase format
format <- toupper(gsub("\\s+",".", format))

# Step 3: Remove suffixes (JR, SR, II, III, IV)
player_name <- gsub("(\\.JR\\.|\\.SR\\.|\\.III|\\.II|\\.IV)$","", format)

# Result: "JOHN.SMITH"
```

---

## Error Handling Patterns

### Safe Scraping Template:
```R
tryCatch(
  scrape_game(game_id, ...),
  error = function(e) {
    print(paste0("Error with game id: ", game_id, " // ", e))
    return(NA)  # Returns NA which is filtered out
  }
)
```

### File Caching Pattern:
```R
# Option 1: Save raw HTML for reuse
if (save_file & !is.na(base_path)) {
  writeLines(html, file_path)
}

# Option 2: Use cached file if available
if (use_file & file.exists(file_path)) {
  html <- readLines(file_path)
} else {
  # Fetch from web with User-Agent header
  file_url <- url(url_text, headers = c("User-Agent" = "..."))
  html <- readLines(con = file_url, warn=F)
}
```

---

## What's Gender-Specific?

### Likely Different:
- Season IDs (dates differ between MBB and WBB seasons)
- Team IDs (different database)
- Some team names may include "(Women's)" qualifier

### Likely Same:
- Conference IDs (most conferences are mixed gender)
- URL structure (probably `/contests/{id}/play_by_play/`)
- HTML table structure
- Event types and player formats
- All analysis functions (once data retrieved)

---

## Testing Checklist for WBB

- [ ] Find actual WBB game on stats.ncaa.org
- [ ] Test URL patterns (note game_id)
- [ ] Verify HTML table structure matches
- [ ] Check table indices for PBP/box scores
- [ ] Verify team name parsing
- [ ] Confirm player name format
- [ ] Test season ID for date range
- [ ] Build test dataset (10+ games)
- [ ] Run get_lineups() on test data
- [ ] Verify on_off calculations
- [ ] Check player stats aggregation
- [ ] Create WBB teamids database
- [ ] Test all 19 exported functions

