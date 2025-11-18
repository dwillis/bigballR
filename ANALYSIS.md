# bigballR Repository - Comprehensive Analysis

## 1. Repository Overview

**Package**: bigballR - NCAA Basketball Data Analysis in R  
**Current Status**: Active maintenance (last commit: Nov 10, 2024)  
**Current Branch**: claude/adapt-womens-basketball-012QveXFhcb912RKhhzb71o4  
**Author**: Jake Flancer  

### Package Purpose
An R package designed to work with NCAA Basketball data, providing users the ability to:
- Retrieve and manipulate play-by-play data
- Work with schedules and rosters
- Calculate lineups and on/off statistics
- Generate player and team statistics
- Visualize game data and player stints

---

## 2. Repository Structure

```
bigballR/
├── R/                          # Main R functions
│   ├── all_functions.R         # Core scraping and data processing (3,528 lines)
│   ├── get_player_combos.R     # Player combination analysis
│   ├── plot_player_stints.R    # Game stint visualization
│   └── scrape_box_score.R      # Box score scraping (deprecated)
├── data/
│   └── teamids.RData           # Team ID lookup table (binary RData file)
├── man/                        # R documentation files (.Rd format)
├── DESCRIPTION                 # Package metadata
├── NAMESPACE                   # Package exports
├── conference_names            # Conference ID mappings
└── README.md                   # User documentation
```

---

## 3. Data Sources & URLs

All data is scraped from **stats.ncaa.org** (NCAA official statistics website).

### Key URL Patterns:

**Play-by-Play Data:**
```
https://stats.ncaa.org/contests/{game_id}/play_by_play/
```

**Box Score Data:**
```
https://stats.ncaa.org/contests/{game_id}/individual_stats
```

**Team Schedule:**
```
https://stats.ncaa.org/teams/{team_id}
```

**Team Roster:**
```
https://stats.ncaa.org/teams/{team_id}/roster
```

**Game Schedules by Date:**
```
https://stats.ncaa.org/season_divisions/{season_id}/scoreboards?game_date={date}&conference_id={conf_id}&commit=Submit
```

### Critical Configuration Data:

1. **Season IDs** (hardcoded in code - Lines 1111-1157 in all_functions.R)
   - Currently covers 2010-2025 seasons
   - Maps dates to NCAA season_division IDs
   - Example: 2024-25 season = ID 18403

2. **Conference IDs** (Lines 1167-1200, also in conference_names file)
   - 30+ NCAA conferences mapped to numeric IDs
   - Examples: ACC=821, SEC=911, Big Ten=827, Pac-12=905

3. **Team IDs** (stored in data/teamids.RData)
   - Binary RData file containing team lookups
   - Fields: Team name, Conference, Season, ID
   - Covers multiple seasons (2016-17 onwards)

---

## 4. Current Architecture: Men's Basketball Flow

### Data Retrieval Pipeline:

```
User Request
    ↓
get_team_schedule() OR get_date_games()
    ↓
HTML fetched from stats.ncaa.org/teams/{id} or season_divisions/
    ↓
XML::readHTMLTable() parses HTML tables
    ↓
Data cleaning & team name extraction
    ↓
Returns: Game IDs, opponents, scores, dates
    ↓
get_play_by_play(game_ids)
    ↓
scrape_game(game_id) for each game
    ↓
Parses HTML tables into play-by-play format
    ↓
Detects V1 vs V2 NCAA format & converts events
    ↓
Identifies on-court players via substitution tracking
    ↓
Returns: Full play-by-play with player tracking
    ↓
get_lineups() - groups by player combinations
    ↓
Statistical aggregation (points, assists, etc.)
```

### Core Scraping Functions:

1. **scrape_game()** (Line 50)
   - Fetches individual game play-by-play HTML
   - Detects NCAA format (V1 or V2)
   - Parses substitutions to determine on-court players
   - Returns: 30+ columns including player names, event types, scores

2. **get_play_by_play()** (Line 1685)
   - Wrapper that processes multiple game IDs
   - Handles errors gracefully
   - Aggregates results into single dataframe

3. **get_team_schedule()** (Line 1364)
   - Extracts schedule from team page HTML
   - Uses regex to parse game IDs from links
   - Handles home/away/neutral site logic
   - Parses results and opponent information

4. **get_team_roster()** (Line 1581)
   - Fetches roster from team roster page
   - Parses player names, positions, heights, years
   - Cleans name formatting

5. **get_date_games()** (Line 1099)
   - Queries games by date and conference
   - Uses season_divisions endpoint
   - Returns schedule with Game IDs for PBP

6. **scrape_box()** (Line 3297)
   - Gets individual box scores
   - Parses player statistics tables
   - Handles team and opponent totals

### Key Supporting Functions:

- **get_lineups()** (Line 1756): Aggregates PBP into lineup stats
- **on_off_generator()** (Line 2366): On/off statistics
- **get_player_stats()** (Line 2621): Player-level stats
- **get_box_scores()** (Line 3396): Batch box score processing
- **convert_events()** (Line 2990): Converts V2 event format to V1
- **get_possessions()** (Line 3469): Possession-level aggregation

---

## 5. Key Code Patterns & Technologies

### Libraries Used:
- **XML**: HTML parsing (`readHTMLTable()`)
- **dplyr**: Data manipulation
- **rvest**: Web scraping utilities
- **stringr**: String processing & regex
- **ggplot2**: Visualization
- **igraph/ggraph**: Network visualization
- **gtools**: Combinations generation
- **glue**: String interpolation

### Web Scraping Approach:
```R
# Pattern used throughout:
file_url <- url(url_text, headers = c("User-Agent" = "My Custom User Agent"))
html <- readLines(con = file_url, warn=F)
close(file_url)
table <- XML::readHTMLTable(html)
```

### Name Normalization Pattern:
```R
# Convert to format: FIRST.LAST
format <- gsub("[^[:alnum:] ]", "", clean_name)
format <- toupper(gsub("\\s+",".", format))
# Remove suffixes: JR, SR, II, III, IV
player_name <- gsub("(\\.JR\\.|\\.SR\\.|\\.III|\\.II|\\.IV)$","", format)
```

### Table Index Numbers:
Functions use hardcoded table indices to extract data:
- `table[[1]]` - Background/game info
- `table[[2]]` - Half scores
- `table[[4]]` - First half play-by-play
- `table[[5]]` - Second half play-by-play
- `table[[5+i]]` - Overtime periods

---

## 6. Data Structures

### Play-by-Play DataFrame (output of scrape_game):
- **ID**: Game ID
- **Date, Time, Game_Time, Game_Seconds**: Temporal data
- **Home, Away**: Team names
- **Home_Score, Away_Score**: Running scores
- **Event_Team**: Which team's event
- **Event_Description, Event_Type**: What happened
- **Player_1, Player_2**: Players involved
- **Event_Result**: Made/missed for shots
- **Shot_Value**: 1, 2, or 3 points
- **Home.1-5, Away.1-5**: Players on court (5 per team)
- **Status**: Data cleanliness flag
- **Additional columns**: Half_Status, isTransition, isGarbageTime, Poss_Num, etc.

### Team Schedule DataFrame (get_team_schedule):
- **Date, Home, Away**: Game info
- **Home_Score, Away_Score**: Final scores
- **Game_ID, Box_ID**: IDs for PBP/box
- **isNeutral**: Neutral site flag
- **Detail**: OT info or cancellation status
- **Opponent_with_detail**: Full opponent string

### Box Score DataFrame (scrape_box):
- **Box_ID, Game_ID**: Game identifier
- **Team**: Team name
- **Player, CleanName**: Player info
- **Name, Pos**: Position
- **FG, FGA, 3FG, 3FGA, FT, FTA**: Shooting stats
- **PTS, ORB, DRB, TRB, AST, TO, STL, BLK**: Standard stats
- **Fouls, TechFouls, DQ**: Disciplinary

### Lineup DataFrame (get_lineups):
- **P1-P5, Team**: Home lineup players
- **oP1-oP5, oTeam**: Away lineup players
- **Mins, oPOSS, dPOSS**: Time and possession data
- **PTS, dPTS**: Points for/against
- **FGA, FGM, TPA, TPM, FTA, FTM**: Shooting breakdown
- **ORB, DRB, BLK, TO, AST**: Ball movement
- **ORTG, DRTG, NETRTG, eFG., TS., etc.**: Calculated stats

---

## 7. Critical Dependencies

### Hardcoded Season IDs (Lines 1111-1157):
```R
2024-25: 18403
2023-24: 18221
2022-23: 17940
2021-22: 17783
2020-21: 17420
2019-20: 17060
2018-19: 16700
2017-18: 13533
2016-17: 13100
```

**IMPORTANT**: These must be updated or replaced for women's basketball (if different).

### Hardcoded Conference IDs (30+ mappings):
- ACC, SEC, Big Ten, Pac-12, Big 12, etc.
- Located in lines 1167-1200 and conference_names file
- These should be mostly identical for women's basketball

### Team ID Database (data/teamids.RData):
- Currently contains only men's basketball team IDs
- Must be replaced or expanded with women's basketball team IDs

### NCAA Website Structure:
- Assumes specific HTML table positions (table[[1]], [[4]], [[5]], etc.)
- Assumes specific CSS selectors for team names
- Relies on specific HTML structure of stats.ncaa.org
- May break if NCAA redesigns website (has happened - see commits)

---

## 8. Recent Updates & Maintenance Notes

### Recent Fixes (from git log):
1. **Nov 10, 2024** (#67): Fixed team name scraping to preserve state abbreviations like "(OH)" after Miami
2. **Nov 2024** (#65): Fixed player exclusion bug in box scores after NCAA UI change
3. **2024**: Updated for 2024-25 season (season ID 18403)
4. **Multiple prior fixes**: Website structure changes, D2 team issues, date format issues

### Known Fragilities:
- Code breaks when NCAA.com changes HTML structure
- Season IDs must be manually updated yearly
- Table indices may shift with website changes
- Regex patterns depend on specific text formatting

---

## 9. What Would Need to Change for Women's Basketball

### 1. **URL Patterns** (Likely Changes)
   - Men's: `https://stats.ncaa.org/contests/{game_id}/play_by_play/`
   - Women's: May need gender parameter or different URL structure
   - **Action**: Research if WBB uses same base URL or has separate endpoint

### 2. **Season IDs**
   - Create separate season ID mappings for women's basketball
   - May differ from men's season IDs
   - **Action**: Scrape NCAA site to find WBB season IDs for each year

### 3. **Team ID Database**
   - Current `data/teamids.RData` is men's only
   - Need to create women's team ID database
   - **Action**: Build/scrape WBB teamids with same structure (Team, Conference, Season, ID)

### 4. **HTML Table Structures**
   - Table indices (table[[1]], [[4]], [[5]]) may differ
   - Team name extraction regex may need adjustment
   - Player name positions might be different
   - **Action**: Test scraping on actual WBB games to verify structure

### 5. **Package Structure Options**
   ```
   Option A: Parallel functions (get_wbb_team_schedule, etc.)
   Option B: Add 'gender' parameter to all functions
   Option C: Separate packages (bigballR for MBB, bigballRw for WBB)
   Option D: Conditional parameters with defaults
   ```

### 6. **Function Parameters**
   Need to add gender/sport specification:
   ```R
   scrape_game(game_id, sport = "MBB", ...)
   get_team_schedule(team.id, sport = "MBB", ...)
   get_date_games(date, conference, sport = "MBB", ...)
   ```

### 7. **Team Names & Conference Mappings**
   - Some conferences are gender-specific
   - Team names may differ (e.g., "Ohio State Men's Basketball" vs "Ohio State Women's Basketball")
   - **Action**: Verify conference IDs are same for women's and men's

### 8. **Season ID Mapping**
   - Create separate season ID lookup for WBB
   - WBB seasons may have different dates (typically earlier start, later finish)
   - **Action**: Map WBB season IDs for all covered years

### 9. **Documentation**
   - Update README with gender parameter documentation
   - Add examples for women's basketball
   - Document any structural differences discovered

### 10. **Testing Strategy**
   - Test scraping on actual WBB games
   - Verify table structures match expectations
   - Check player name handling
   - Validate team ID extraction

---

## 10. File Locations Summary

| Component | Location | Purpose |
|-----------|----------|---------|
| Main functions | `/home/user/bigballR/R/all_functions.R` | Core scraping & analysis (3,528 lines) |
| Player combos | `/home/user/bigballR/R/get_player_combos.R` | Player combination stats |
| Stint plotting | `/home/user/bigballR/R/plot_player_stints.R` | Game visualization |
| Box score (legacy) | `/home/user/bigballR/R/scrape_box_score.R` | Deprecated function |
| Team IDs | `/home/user/bigballR/data/teamids.RData` | Binary lookup table |
| Conference IDs | `/home/user/bigballR/conference_names` | Conference mapping file |
| Documentation | `/home/user/bigballR/man/` | .Rd help files |
| Package config | `/home/user/bigballR/DESCRIPTION` | Package metadata |
| Exports | `/home/user/bigballR/NAMESPACE` | Function exports |
| README | `/home/user/bigballR/README.md` | User documentation |

---

## 11. Exported Functions (Public API)

**Data Retrieval:**
- `get_date_games()` - Games on a specific date/conference
- `get_team_schedule()` - Team's full schedule
- `get_team_roster()` - Team roster with player details
- `scrape_game()` - Individual game play-by-play
- `get_play_by_play()` - Multiple games PBP

**Box Scores:**
- `scrape_box()` - Individual game box score
- `get_box_scores()` - Multiple game box scores

**Analysis:**
- `get_lineups()` - Lineup statistics
- `on_off_generator()` - On/off stats
- `get_player_stats()` - Player stats (game or aggregate)
- `get_player_lineups()` - Filter lineups by player
- `get_player_combos()` - Player combination stats
- `get_possessions()` - Possession-level data
- `get_team_stats()` - Team statistics

**Visualization:**
- `plot_player_stints()` - Game stint chart
- `plot_mins_dist()` - Playing time distribution
- `plot_duos()` - Player duo analysis

---

## 12. Key Insights for Women's Basketball Adaptation

1. **URL Structure**: Primary uncertainty - need to verify if WBB uses same stats.ncaa.org infrastructure

2. **Team Identification**: New team ID mapping needed - this is critical for all functions

3. **Season IDs**: Different for WBB - need separate mapping table

4. **HTML Structure**: Likely similar but must verify table positions and team name locations

5. **Existing Code Robustness**: Package has good error handling and already adapts to NCAA website changes

6. **Modular Design**: Core functions are well-separated, making adaptation easier

7. **Configuration Centralization**: Season/conference IDs should be extracted to config file (not hardcoded)

8. **Feature Parity**: Once URLs/IDs verified, all analysis functions should work identically

