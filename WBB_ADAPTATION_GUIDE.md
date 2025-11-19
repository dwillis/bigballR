# Women's Basketball Adaptation Guide

## Executive Summary

The `bigballR` package is a well-structured R package for scraping and analyzing NCAA men's basketball data from stats.ncaa.org. Adapting it for women's basketball requires investigation of the NCAA's URL structure for women's games, updating team/season ID mappings, and verifying HTML parsing logic.

**Estimated Effort**: Medium (3-5 days)  
**Risk Level**: Low-Medium (depends on URL/HTML structure differences)  
**Confidence in Full Success**: High (once URLs verified)

---

## Phase 1: Investigation (Days 1-2)

### Task 1.1: Verify Women's Basketball URLs
**Objective**: Determine if WBB uses the same base URL structure as MBB

**Actions**:
1. Visit stats.ncaa.org and find a women's basketball game
2. Note the URLs:
   - Play-by-play: Compare structure to MBB format
   - Box scores: Compare structure to MBB format
   - Team schedule: Compare structure to MBB format
   - Roster: Compare structure to MBB format

3. Create test URLs for both MBB and WBB:
   ```R
   # Test if this works for WBB:
   mbb_url <- "https://stats.ncaa.org/contests/123456/play_by_play/"
   wbb_url <- "https://stats.ncaa.org/contests/123456/play_by_play/"  # Same?
   ```

4. Document findings:
   - Is the base URL identical?
   - Are game IDs the same format?
   - Are table structures in HTML identical?

### Task 1.2: Find Women's Basketball Season IDs
**Objective**: Map dates to NCAA season_division IDs for WBB

**Actions**:
1. Visit stats.ncaa.org/season_divisions/ and browse for women's basketball
2. Check for each season (2024-25, 2023-24, etc.):
   - What is the season ID?
   - Is it the same as men's?
   - If different, how do they differ?

3. Document the WBB season IDs:
   ```R
   wbb_season_ids <- list(
     "2024-25" = ?,
     "2023-24" = ?,
     "2022-23" = ?,
     # etc...
   )
   ```

### Task 1.3: Build Women's Team ID Database
**Objective**: Create teamids dataset for women's basketball

**Actions**:
1. Determine how to get team IDs:
   - Option A: Manually map (15-20 hours)
   - Option B: Web scrape from NCAA site (2-3 hours)
   - Option C: Find existing database online

2. Create structure matching existing format:
   ```R
   wbb_teamids <- data.frame(
     Team = "Duke",           # Team school name
     Conference = "ACC",       # Conference
     Season = "2023-24",      # Season
     ID = 123456              # NCAA team ID
   )
   ```

3. Cover all seasons in existing database (2016-17 onwards)

### Task 1.4: Verify HTML Structure
**Objective**: Confirm table indices match for WBB

**Actions**:
1. Fetch HTML from WBB play-by-play game
2. Parse with `XML::readHTMLTable()`
3. Check table positions:
   - Is table[[2]] the half scores?
   - Is table[[4]] the first half PBP?
   - Is table[[5]] the second half PBP?
4. If different, update code accordingly

---

## Phase 2: Implementation (Days 3-4)

### Task 2.1: Add Gender Parameter
**Objective**: Extend functions to support both MBB and WBB

**Approach**: Add optional `sport` parameter to key functions

**Files to modify**:
1. `/home/user/bigballR/R/all_functions.R`
   - Add `sport = "MBB"` parameter to:
     - `scrape_game()`
     - `get_play_by_play()`
     - `get_team_schedule()`
     - `get_team_roster()`
     - `get_date_games()`
     - `scrape_box()`
     - `get_box_scores()`

**Implementation pattern**:
```R
scrape_game <- function(game_id, sport = "MBB", 
                        save_file = F, use_file = F, 
                        base_path = NA, overwrite = F) {
  
  # Build URL based on sport parameter
  if (sport == "MBB") {
    url_text <- glue::glue("https://stats.ncaa.org/contests/{game_id}/play_by_play/")
  } else if (sport == "WBB") {
    # May be same or different - use findings from Phase 1
    url_text <- glue::glue("https://stats.ncaa.org/contests/{game_id}/play_by_play/")
  }
  
  # Rest of function proceeds identically
  # ...
}
```

### Task 2.2: Create Season ID Lookup Functions
**Objective**: Centralize season ID logic

**Implementation**:
```R
get_season_id <- function(date, sport = "MBB") {
  dateform <- as.Date(as.character(date), format = "%m/%d/%Y")
  
  if (sport == "MBB") {
    seasonid <- dplyr::case_when(
      dateform > as.Date("2024-05-01") & dateform <= as.Date("2025-05-01") ~ 18403,
      # ... existing logic ...
    )
  } else if (sport == "WBB") {
    seasonid <- dplyr::case_when(
      dateform > as.Date("2024-05-01") & dateform <= as.Date("2025-05-01") ~ ?,  # WBB ID
      # ... WBB season IDs ...
    )
  }
  
  return(seasonid)
}
```

### Task 2.3: Create Team ID Lookup Functions
**Objective**: Support both MBB and WBB team databases

**Implementation**:
```R
get_team_id <- function(team.name, season, sport = "MBB") {
  if (sport == "MBB") {
    team.id <- bigballR::teamids$ID[
      which(bigballR::teamids$Team == team.name & 
            bigballR::teamids$Season == season)
    ]
  } else if (sport == "WBB") {
    team.id <- bigballR::wbb_teamids$ID[
      which(bigballR::wbb_teamids$Team == team.name & 
            bigballR::wbb_teamids$Season == season)
    ]
  }
  return(team.id)
}
```

### Task 2.4: Update Conference ID Logic
**Objective**: Add WBB conference IDs if different

**Actions**:
1. Verify if conference IDs are identical for WBB
2. If different, update `get_date_games()` function:
```R
get_conference_id <- function(conference, sport = "MBB") {
  conferenceform <- tolower(sub("[^[:alnum:]=\\.]", "", conference))
  
  if (sport == "MBB") {
    conferenceid <- dplyr::case_when(
      conferenceform == "aac" ~ 823,
      # ... existing mapping ...
    )
  } else if (sport == "WBB") {
    # May be identical, just route to same mapping
    conferenceid <- dplyr::case_when(
      conferenceform == "aac" ~ 823,  # Likely same
      # ...
    )
  }
  
  return(conferenceid)
}
```

### Task 2.5: Create WBB TeamIDs Dataset
**Objective**: Build and include WBB team database

**Actions**:
1. Create wbb_teamids dataframe from Phase 1 findings
2. Save as R object:
   ```R
   # In R console:
   wbb_teamids <- data.frame(...)  # WBB teams
   save(wbb_teamids, file = "data/wbb_teamids.RData")
   ```
3. Update NAMESPACE to export both datasets:
   ```
   data(teamids)      # MBB
   data(wbb_teamids)  # WBB
   ```

### Task 2.6: Update Documentation
**Actions**:
1. Update README.md with WBB examples
2. Update function docstrings to mention `sport` parameter
3. Add vignette showing WBB workflow
4. Update DESCRIPTION if needed

---

## Phase 3: Testing (Day 5)

### Task 3.1: Unit Testing
**Test each function**:
```R
# Test get_date_games for WBB
wbb_games <- get_date_games(date = "03/15/2024", 
                            conference = "ACC", 
                            sport = "WBB")

# Test get_team_schedule for WBB
schedule <- get_team_schedule(team.name = "Duke", 
                             season = "2023-24", 
                             sport = "WBB")

# Test scrape_game for WBB
pbp <- scrape_game(game_id = "123456", sport = "WBB")

# Test get_play_by_play for WBB
multi_pbp <- get_play_by_play(c("123456", "123457"), sport = "WBB")

# Test get_box_scores for WBB
boxes <- get_box_scores(c("123456", "123457"), sport = "WBB")
```

### Task 3.2: Integration Testing
**Test full workflows**:
```R
# Workflow 1: Schedule → PBP → Lineups
schedule <- get_team_schedule(team.name = "Duke", season = "2023-24", sport = "WBB")
pbp <- get_play_by_play(schedule$Game_ID, sport = "WBB")
lineups <- get_lineups(pbp)

# Workflow 2: On/off analysis
on_off <- on_off_generator("PLAYER.NAME", lineups)

# Workflow 3: Player combo analysis
combos <- get_player_combos(lineups, n = 2, min_mins = 50)

# Workflow 4: Visualization
plot_player_stints(pbp[pbp$ID == first_game_id,])
```

### Task 3.3: Regression Testing
**Verify MBB still works**:
```R
# Ensure existing MBB code still works
mbb_schedule <- get_team_schedule(team.name = "Duke", season = "2023-24")  # Default MBB
mbb_schedule2 <- get_team_schedule(team.name = "Duke", season = "2023-24", sport = "MBB")

# Both should be identical
identical(mbb_schedule, mbb_schedule2)
```

---

## Code Modifications Summary

### Files Requiring Changes

1. **`R/all_functions.R`** (main file)
   - Add `sport` parameter to 7 functions
   - Extract hardcoded season IDs to helper function
   - Extract hardcoded conference IDs to helper function
   - Update team ID lookups to use helper function
   - Lines modified: ~100-150 (mostly additions)

2. **`data/wbb_teamids.RData`** (new file)
   - Create women's basketball team ID database
   - Same structure as existing teamids.RData
   - Required for get_team_schedule() with team.name

3. **`NAMESPACE`** (update)
   - Add: `data(wbb_teamids)`
   - Keep existing data(teamids)

4. **`README.md`** (update)
   - Add WBB examples
   - Document `sport` parameter
   - Show WBB workflow

5. **`DESCRIPTION`** (possibly update)
   - Update description if significant change

### Files NOT Requiring Changes

1. `R/get_player_combos.R` - Works with any PBP data
2. `R/plot_player_stints.R` - Works with any PBP data
3. `R/scrape_box_score.R` - Already deprecated
4. `man/*.Rd` - Auto-generated from roxygen
5. All analysis functions (`get_lineups`, `on_off_generator`, etc.)

---

## Backward Compatibility

**IMPORTANT**: All changes should maintain backward compatibility

Strategy:
1. All new `sport` parameters default to `"MBB"`
2. Existing code using functions without `sport` parameter will work identically
3. No changes to existing function outputs
4. No changes to data structures (teamids.RData unchanged)

Example:
```R
# Old code (still works)
schedule <- get_team_schedule(team.name = "Duke", season = "2023-24")

# New code (WBB)
schedule <- get_team_schedule(team.name = "Duke", season = "2023-24", sport = "WBB")

# Both return identical structure, just different data
```

---

## Risk Assessment

### Low Risk Changes:
- Adding optional `sport` parameter to functions
- Creating new season ID mapping
- Creating WBB teamids database
- Analysis functions (no changes needed)

### Medium Risk Changes:
- Hardcoding URL changes if WBB uses different structure
- Table index changes if WBB HTML differs
- Team name parsing if different format needed

### High Risk Changes:
- None identified (low complexity of required changes)

### Mitigation Strategies:
1. Keep all changes optional via `sport` parameter
2. Run full regression test suite for MBB
3. Test on multiple WBB games before release
4. Use try-catch blocks if scraping fails

---

## Implementation Timeline

| Phase | Task | Duration | Effort |
|-------|------|----------|--------|
| 1 | Verify URLs | 2-3 hours | Low |
| 1 | Find season IDs | 2 hours | Low |
| 1 | Build teamids | 3-4 hours | Low-Medium |
| 1 | Verify HTML structure | 2 hours | Low |
| 2 | Add sport parameter | 2-3 hours | Low |
| 2 | Create helpers | 1-2 hours | Low |
| 2 | Update dataset | 1 hour | Low |
| 2 | Update docs | 2 hours | Low |
| 3 | Unit testing | 2-3 hours | Medium |
| 3 | Integration testing | 2 hours | Medium |
| 3 | Regression testing | 1 hour | Low |
| **Total** | | **18-23 hours** | **Medium** |

---

## Success Criteria

- All 19 exported functions work with `sport = "WBB"` parameter
- MBB functionality unchanged (backward compatible)
- At least 10 WBB games successfully scraped and analyzed
- All analysis functions (lineups, on/off, combos) produce valid results
- Documentation updated with WBB examples
- No regressions in MBB testing
- Code passes package check (R CMD check)

---

## References

### Key Files
- Main code: `/home/user/bigballR/R/all_functions.R`
- Team IDs: `/home/user/bigballR/data/teamids.RData`
- Exports: `/home/user/bigballR/NAMESPACE`

### Documentation
- `ANALYSIS.md` - Complete code structure breakdown
- `QUICK_REFERENCE.md` - Quick lookup guide
- `FUNCTION_SIGNATURES.md` - All function details
- `README.md` - Package documentation

### External Resources
- NCAA Stats: https://stats.ncaa.org/
- bigballR GitHub: https://github.com/jflancer/bigballR
- R Package Development: https://r-pkgs.org/

---

## Next Steps

1. **Immediately**: Complete Phase 1 investigation
   - Determine URL structure
   - Identify season IDs
   - Build teamids database

2. **Once Phase 1 complete**: Start Phase 2 implementation
   - Modify functions
   - Update datasets
   - Refactor season ID logic

3. **Testing**: Comprehensive test suite
   - Unit tests for each function
   - Integration tests for workflows
   - Regression tests for MBB

4. **Release**: Submit PR when complete
   - Clean commit history
   - Updated documentation
   - Test evidence

