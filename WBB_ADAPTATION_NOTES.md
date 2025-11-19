# Women's Basketball Adaptation Notes

This document provides important information about the adaptation of bigballR for NCAA Women's Basketball.

## Overview

This package has been adapted from the original bigballR (men's basketball) to work with NCAA Women's Basketball data. The core functionality remains the same, but season IDs, team databases, and some implementation details have been updated for WBB.

## Key Changes

### 1. Season Division IDs

Women's Basketball uses different season division IDs than men's basketball on stats.ncaa.org. The current season IDs in the code are:

- **2024-25**: 18402
- **2023-24**: 18220
- **2022-23**: 17941
- **2021-22**: 17781
- **2020-21**: 17421

These IDs are used in the `get_date_games()` function to construct URLs for retrieving game schedules.

#### How to Find/Verify Season IDs:

1. Go to https://stats.ncaa.org
2. Select "Women's Basketball" from the sport dropdown
3. Select "Division I"
4. Select a season (e.g., "2024-25")
5. Click "Scoreboards" or any games page
6. Look at the URL: `https://stats.ncaa.org/season_divisions/[SEASON_ID]/scoreboards`
7. The number after `season_divisions/` is the season ID

**Note**: If you find that a season ID is incorrect, you can update it in `/R/all_functions.R` starting around line 1115.

### 2. Team IDs

Each team has a unique ID for each season on stats.ncaa.org. These IDs are needed for:
- `get_team_schedule(team.id = ID)`
- `get_team_roster(team.id = ID)`

#### How to Find Team IDs:

**Method 1 - From Team Page:**
1. Go to https://stats.ncaa.org
2. Navigate to a team's page for a specific season
3. Look at the URL: `https://stats.ncaa.org/teams/[TEAM_ID]`
4. The number after `teams/` is the team ID

**Method 2 - From Schedule Results:**
Use `get_date_games()` to retrieve a schedule with team IDs included:
```r
games <- get_date_games(date = "11/15/2024", conference = "SEC")
# Team IDs can be found by navigating to box score pages
```

### 3. Team Database

The package includes WBB team data from the [WBB repository](https://github.com/dwillis/wbb). The team data includes:
- Team names (stats_name)
- NCAA IDs (ncaa_id) - base organization identifiers
- Twitter handles
- Official websites

**Important**: The `ncaa_id` in the teams.json is NOT the same as the season-specific team ID used in stats.ncaa.org URLs.

### 4. Player IDs

The adapted package now extracts player IDs from roster pages when available. Player IDs appear in the `Player_ID` column of the roster dataframe returned by `get_team_roster()`.

These IDs can be used to:
- Link players across seasons
- Access individual player statistics pages
- Track player careers

Player pages follow the format: `https://stats.ncaa.org/players/[PLAYER_ID]`

## URL Patterns

The package uses these URL patterns for WBB (same as MBB):

- **Play-by-play**: `https://stats.ncaa.org/contests/[GAME_ID]/play_by_play/`
- **Box score**: `https://stats.ncaa.org/contests/[GAME_ID]/box_score`
- **Team page**: `https://stats.ncaa.org/teams/[TEAM_ID]`
- **Team roster**: `https://stats.ncaa.org/teams/[TEAM_ID]/roster`
- **Schedule by date**: `https://stats.ncaa.org/season_divisions/[SEASON_ID]/scoreboards?game_date=[DATE]&conference_id=[CONF_ID]`
- **Player page**: `https://stats.ncaa.org/players/[PLAYER_ID]`

## Conference IDs

Conference IDs appear to be the same for both men's and women's basketball. The package includes mappings for major conferences:

- ACC: 821
- Big Ten: 842
- Big 12: 837
- SEC: 864
- Pac-12: 859
- And many others (see all_functions.R lines ~1167-1200)

## Data Quality Notes

1. **Substitution Tracking**: The package tracks substitutions to determine which players are on the court at each moment. Scorekeepers sometimes make errors, which the package attempts to detect and report.

2. **Game IDs**: Not all games have play-by-play data available. Check `schedule$Game_ID` for NA values.

3. **Cancelled Games**: Cancelled or postponed games will have NA game IDs.

## Updating for Future Seasons

When a new season starts:

1. Find the new season division ID (see instructions above)
2. Update `all_functions.R` around line 1116-1118
3. Add a new case_when entry for the new season:
   ```r
   # 25-26 WBB
   dateform > as.Date("2025-05-01") &
     dateform <= as.Date("2026-05-01") ~ [NEW_SEASON_ID],
   ```

## Getting Help

If you encounter issues:

1. Verify your season ID is correct for WBB (not MBB)
2. Check that team IDs are current for the season you're querying
3. Confirm game IDs exist for the games you're trying to scrape
4. Check the [WBB repository](https://github.com/dwillis/wbb) for updated team data

## Example Workflows

### Getting a Full Season of Data

```r
library(bigballR)

# Get schedule for a team (example: South Carolina 2024-25)
schedule <- get_team_schedule(team.id = 560922)

# Get play-by-play for all completed games
pbp <- get_play_by_play(schedule$Game_ID)

# Get lineups and stats
lineups <- get_lineups(pbp, keep.dirty = TRUE, garbage.filter = FALSE)
player_stats <- get_player_stats(pbp, multi.games = TRUE)

# Get roster with player IDs
roster <- get_team_roster(team.id = 560922)
```

### Getting Games by Date and Conference

```r
# Get all SEC games on a specific date
games <- get_date_games(date = "01/15/2025", conference = "SEC")

# Get play-by-play for those games
pbp <- get_play_by_play(games$GameID)
```

### Tracking a Specific Player

```r
# Get roster to find player names
roster <- get_team_roster(team.id = 560922)

# Get season stats
schedule <- get_team_schedule(team.id = 560922)
pbp <- get_play_by_play(schedule$Game_ID)
lineups <- get_lineups(pbp)

# Look at on/off stats for a specific player
# (use player name in format from roster$Player column)
player_on_off <- on_off_generator("PLAYER.NAME", lineups)
```

## Credits

- **Original Package**: Jake Flancer (jflancer)
- **WBB Adaptation**: Derek Willis (dwillis)
- **WBB Team Data**: https://github.com/dwillis/wbb
