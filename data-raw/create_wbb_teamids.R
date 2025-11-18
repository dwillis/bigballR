# Script to create WBB teamids dataset from JSON data
# This creates a simplified teamids structure for Women's Basketball

library(jsonlite)
library(dplyr)

# Read the WBB teams JSON
wbb_teams <- jsonlite::fromJSON("data/wbb_teams.json")

# For WBB, we need to create team IDs for multiple seasons
# The ncaa_id from the JSON appears to be the base team identifier
# We'll need to get the actual season-specific team IDs from stats.ncaa.org

# Create a helper function to build team IDs for multiple seasons
create_wbb_teamids <- function() {

  # Extract basic team information
  base_teams <- wbb_teams %>%
    select(
      Team = stats_name,
      NCAA_ID = ncaa_id
    ) %>%
    filter(!is.na(NCAA_ID))

  # Define WBB seasons (these will need to be updated with actual season IDs from stats.ncaa.org)
  # NOTE: These are placeholder IDs that need to be verified/updated
  # Each season's team pages have unique IDs that can be found at stats.ncaa.org

  seasons <- c("2024-25", "2023-24", "2022-23", "2021-22", "2020-21")

  # For now, create a simple structure
  # Users will need to find specific team.id values from stats.ncaa.org team pages
  # The URL format is: https://stats.ncaa.org/teams/[team.id]

  teamids <- base_teams %>%
    mutate(
      ID = NA_integer_,  # Placeholder - needs to be populated from stats.ncaa.org
      Season = "2024-25",
      Conference = NA_character_  # Can be added later if needed
    ) %>%
    select(Team, ID, Season, Conference, NCAA_ID)

  return(teamids)
}

# Create the dataset
teamids <- create_wbb_teamids()

# Save as RData file
save(teamids, file = "data/teamids.RData")

cat("WBB teamids dataset created with", nrow(teamids), "teams\n")
cat("Note: Team-specific season IDs need to be populated from stats.ncaa.org\n")
cat("Each team's page URL (https://stats.ncaa.org/teams/[ID]) contains the season-specific ID\n")
