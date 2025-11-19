# bigballR - Function Signatures & Dependencies

## Exported Functions (Public API)

### Data Retrieval Functions

```R
# Retrieve games by date and conference
get_date_games(date = as.character(format(Sys.Date()-1, "%m/%d/%Y")),
               conference = "All",
               conference.ID = NA,
               use_file = F,
               save_file = F,
               base_path = NA)
# Returns: DataFrame with game_id, date, teams, scores

# Get team's schedule
get_team_schedule(team.id = NA,
                  season = NA,
                  team.name = NA,
                  use_file = F,
                  save_file = F,
                  base_path = NA,
                  overwrite = F)
# Dependencies: teamids RData, team.id or (team.name + season)
# Returns: DataFrame with dates, opponents, scores, Game_IDs

# Get team's roster
get_team_roster(team.id = NA,
                season = NA,
                team.name = NA,
                use_file = F,
                save_file = F,
                base_path = NA,
                overwrite = F)
# Returns: DataFrame with Jersey, Player, Position, Height, Year, CleanName

# Get single game play-by-play
scrape_game(game_id,
            save_file = F,
            use_file = F,
            base_path = NA,
            overwrite = F)
# URL: https://stats.ncaa.org/contests/{game_id}/play_by_play/
# Returns: Full play-by-play with on-court players

# Get multiple games play-by-play
get_play_by_play(game_ids,
                 use_file = F,
                 save_file = F,
                 base_path = NA,
                 overwrite = F)
# Calls scrape_game() for each ID
# Returns: Combined play-by-play dataframe
```

### Box Score Functions

```R
# Get single game box score
scrape_box(game_id,
           use_file = F,
           save_file = F,
           base_path = NA,
           overwrite = F)
# URL: https://stats.ncaa.org/contests/{game_id}/individual_stats
# Returns: Player stats for single game

# Get multiple game box scores
get_box_scores(game_ids,
               multi.games = F,
               use_file = F,
               save_file = F,
               base_path = NA,
               overwrite = F)
# If multi.games = T: aggregates across games
# Returns: Player game stats (or season aggregate if multi.games = T)

# Deprecated - don't use
scrape_box_score(game_id)
# Returns: NA with message to use scrape_box instead
```

### Analysis Functions

```R
# Convert play-by-play to lineup level
get_lineups(play_by_play_data = NA,
            include_transition = F)
# Dependencies: play-by-play data from scrape_game()
# Returns: Lineup stats with 50+ metrics (ORTG, DRTG, NETRTG, etc.)

# Calculate on/off statistics
on_off_generator(Players = NA,
                 Lineup_Data = NA,
                 Included = NA,
                 Excluded = NA)
# Dependencies: lineup data from get_lineups()
# Returns: On/off comparison stats for specified players

# Get player statistics
get_player_stats(play_by_play_data = NA,
                 multi.games = F,
                 simple = F)
# Returns: Player stats from play-by-play (game or season aggregate)

# Filter lineups by player
get_player_lineups(Lineup_Data = NA,
                   Players = NA,
                   Included = NA,
                   Excluded = NA)
# Returns: Filtered subset of lineup data

# Player combination statistics
get_player_combos(Lineup_Data = NA,
                  n = 2,
                  min_mins = 0,
                  Included = NA,
                  Excluded = NA,
                  include_transition = F)
# Calculates stats for n-player combinations (n = 1-5)
# Returns: Stats when specified players play together

# Possession-level data
get_possessions(play_by_play_data = NA,
                simple = F)
# Returns: One row per possession with result and participants

# Team statistics
get_team_stats(play_by_play_data = NA,
               multi.games = F,
               simple = F)
# Returns: Team aggregate statistics
```

### Visualization Functions

```R
# Plot game stints
plot_player_stints(play_by_play_data = NA)
# Input: Single game play-by-play only
# Returns: ggplot object showing stints with +/- coloring

# Plot playing time distribution
plot_mins_dist(play_by_play_data = NA,
               team = NA,
               threshold = NA,
               split_position = F)
# Returns: ggplot visualization of minutes distribution

# Plot player duo analysis
plot_duos(Lineup_Data = NA,
          team = NA,
          min_mins = 0,
          regressed_poss = 50)
# Returns: Network visualization of player pairings
```

---

## Internal/Helper Functions

```R
# Convert NCAA format V2 events to V1 format
convert_events(events)
# Used internally by scrape_game()

# Extract minutes played from play-by-play
get_mins(play_by_play_data)
# Returns: Dataframe of minutes by player

# Helper functions in get_player_combos.R
team_comb(team_lineups, mins = 0, n = 2, include_transition = F)
get_player_stints(player, game_data)
get_player_stints_helper(...)  # Various internal functions
```

---

## Function Dependencies & Call Graph

```
User API Calls
    ↓
┌────────────────────────────────────────────────────────┐
│ Schedule/Roster Functions (Independent)                │
├────────────────────────────────────────────────────────┤
│ get_date_games()           → teamids lookup            │
│ get_team_schedule()        → teamids lookup            │
│ get_team_roster()          → teamids lookup            │
│                                                        │
│ [Dependencies: teamids.RData, season IDs, conf IDs]   │
└────────────────────────────────────────────────────────┘
         ↓
    Game IDs acquired
         ↓
┌────────────────────────────────────────────────────────┐
│ Play-by-Play Scraping (Core)                           │
├────────────────────────────────────────────────────────┤
│ get_play_by_play()                                     │
│   ├─ scrape_game() [for each game_id]                 │
│   │   ├─ XML::readHTMLTable() → Parse tables          │
│   │   ├─ convert_events() → Normalize V2→V1           │
│   │   └─ [Substitution tracking, on-court lineup logic]
│   └─ Bind results
│                                                        │
│ [Dependencies: Game ID, NCAA stats.ncaa.org]          │
└────────────────────────────────────────────────────────┘
         ↓
    Play-by-play DataFrame
         ↓
┌────────────────────────────────────────────────────────┐
│ Box Score Scraping (Parallel)                          │
├────────────────────────────────────────────────────────┤
│ get_box_scores()                                       │
│   ├─ scrape_box() [for each game_id]                  │
│   │   └─ XML::readHTMLTable() → Parse tables          │
│   └─ Bind results                                      │
│                                                        │
│ [Dependencies: Game ID, NCAA stats.ncaa.org]          │
└────────────────────────────────────────────────────────┘
         ↓
    Box Score DataFrame
         ↓
┌────────────────────────────────────────────────────────┐
│ Analysis Layer (Depends on PBP)                        │
├────────────────────────────────────────────────────────┤
│                                                        │
│ get_lineups(pbp)                                       │
│   └─ dplyr::group_by() + summarise()                  │
│   └─ Returns: Lineup-level stats                      │
│       ↓                                                │
│       ├─ on_off_generator(lineups, player)            │
│       │   └─ Filter & compare lineups                 │
│       │                                               │
│       ├─ get_player_combos(lineups)                   │
│       │   └─ team_comb() [internal]                  │
│       │   └─ gtools::combinations()                   │
│       │                                               │
│       └─ get_player_lineups(lineups, player)         │
│           └─ dplyr::filter()                          │
│                                                        │
│ get_player_stats(pbp)                                  │
│   └─ dplyr::group_by() + summarise()                  │
│                                                        │
│ get_possessions(pbp)                                   │
│   └─ Possession-level aggregation                     │
│                                                        │
│ get_team_stats(pbp)                                    │
│   └─ Team-level aggregation                           │
│                                                        │
│ [Dependencies: Play-by-play DataFrame]                │
└────────────────────────────────────────────────────────┘
         ↓
    Aggregated statistics
         ↓
┌────────────────────────────────────────────────────────┐
│ Visualization Layer (Depends on PBP/Lineups)          │
├────────────────────────────────────────────────────────┤
│ plot_player_stints(pbp)        → ggplot               │
│ plot_mins_dist(pbp)            → ggplot               │
│ plot_duos(lineups)             → igraph               │
│                                                        │
│ [Dependencies: ggplot2, igraph, ggraph]               │
└────────────────────────────────────────────────────────┘
         ↓
    Visualizations
```

---

## Data Flow Examples

### Example 1: Get Team's Season Statistics
```R
# Step 1: Get schedule
schedule <- get_team_schedule(team.name = "Duke", season = "2023-24")
# Returns: Date, Home, Away, Home_Score, Away_Score, Game_ID

# Step 2: Get all play-by-play
pbp <- get_play_by_play(schedule$Game_ID)
# Returns: Event-level data with on-court players

# Step 3: Calculate team statistics
team_stats <- get_team_stats(pbp, multi.games = T)
# Returns: Season aggregate stats
```

### Example 2: On/Off Analysis
```R
# Step 1: Get play-by-play
pbp <- get_play_by_play(game_ids)

# Step 2: Convert to lineup level
lineups <- get_lineups(pbp)
# Returns: Lineup-level stats

# Step 3: Analyze impact of specific player
player_impact <- on_off_generator("ZION.WILLIAMSON", lineups)
# Returns: ZION on court vs off court comparison

# Step 4: Further filter
with_costar <- on_off_generator(
  "ZION.WILLIAMSON",
  lineups,
  Included = "RJ.BARRETT"
)
# Only includes lineups where both are on court vs ZION only
```

### Example 3: Player Duo Analysis
```R
# Step 1: Get lineups
lineups <- get_lineups(pbp_data)

# Step 2: Get 2-player combinations
duos <- get_player_combos(lineups, n = 2, min_mins = 50)
# Only duos with 50+ combined minutes

# Step 3: Visualize
plot_duos(lineups, min_mins = 50)
# Network graph of player pairings
```

---

## Key Dependencies & Imports

```R
# From DESCRIPTION file:
Imports:
  dplyr              # Data manipulation
  XML                # HTML parsing
  stringr            # String/regex operations
  magrittr           # Pipe operator (deprecated, use |>)
  ggplot2            # Visualization
  igraph             # Network graphs
  ggraph             # Network visualization
  gtools             # Combinations function
  rvest              # Web scraping helpers
  
Additional (used in code):
  glue               # String interpolation
  tidyr              # Data reshaping
```

---

## Parameter Patterns

### Common Parameters Across Functions

**File caching parameters** (for local efficiency):
- `use_file = FALSE` - Use cached local files
- `save_file = FALSE` - Save HTML for future reuse
- `base_path = NA` - Directory for cache files
- `overwrite = FALSE` - Overwrite existing cache

**Aggregation parameters**:
- `multi.games = FALSE` - Game-level (T) vs. season-level (F)
- `simple = FALSE` - Simplified output
- `include_transition = FALSE` - Include transition stats

**Filter parameters**:
- `Included = NA` - Players who must be on court
- `Excluded = NA` - Players who must be off court
- `min_mins = 0` - Minimum minutes threshold
- `team = NA` - Filter to specific team

---

## Critical Code Sections

### Most Fragile (likely to break with NCAA changes):
1. HTML table indices (table[[1]], [[4]], [[5]])
2. Team name extraction regex patterns
3. Season ID hardcoded mappings (lines 1111-1157)
4. Conference ID case_when() branches (lines 1167-1200)

### Most Robust (unlikely to need changes):
1. Player name normalization (general approach)
2. Event type detection logic
3. On-court player tracking algorithm
4. Statistics calculation formulas (ORTG, eFG%, etc.)

