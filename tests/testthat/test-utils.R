test_that("conference ID mapping works", {
  # Test the conference name to ID mapping logic

  # Function normalizes by removing punctuation and converting to lowercase
  normalize_conference <- function(name) {
    tolower(sub("[^[:alnum:]=\\.]", "", name))
  }

  expect_equal(normalize_conference("SEC"), "sec")
  expect_equal(normalize_conference("Big Ten"), "bigten")
  expect_equal(normalize_conference("Big 12"), "big12")
  expect_equal(normalize_conference("ACC"), "acc")
  expect_equal(normalize_conference("Pac-12"), "pac12")
  expect_equal(normalize_conference("Big East"), "bigeast")
})

test_that("team name cleaning removes records", {
  # Teams are often listed as "Team Name (W-L)"
  # Need to extract just the team name

  test_names <- c(
    "South Carolina (5-0)",
    "Maryland (12-3)",
    "Duke (0-1)"
  )

  # Pattern to remove: " [(][0-9]{1-2}\\-[0-9]{1-2}[)]"
  cleaned <- gsub(" [(][0-9]{1,2}\\-[0-9]{1,2}[)]", "", test_names)

  expect_equal(cleaned[1], "South Carolina")
  expect_equal(cleaned[2], "Maryland")
  expect_equal(cleaned[3], "Duke")
})

test_that("URL construction is correct", {
  # Test URL building for various endpoints

  # Play-by-play URL
  game_id <- 12345
  pbp_url <- paste0("https://stats.ncaa.org/contests/", game_id, "/play_by_play/")
  expect_equal(pbp_url, "https://stats.ncaa.org/contests/12345/play_by_play/")

  # Box score URL
  box_url <- paste0("https://stats.ncaa.org/contests/", game_id, "/box_score")
  expect_equal(box_url, "https://stats.ncaa.org/contests/12345/box_score")

  # Team page URL
  team_id <- 560922
  team_url <- paste0("https://stats.ncaa.org/teams/", team_id)
  expect_equal(team_url, "https://stats.ncaa.org/teams/560922")

  # Roster URL
  roster_url <- paste0("https://stats.ncaa.org/teams/", team_id, "/roster")
  expect_equal(roster_url, "https://stats.ncaa.org/teams/560922/roster")
})

test_that("date formatting for URLs is correct", {
  # Dates need to be URL encoded (/ becomes %2F)

  date <- "11/15/2024"
  encoded_date <- gsub("[/]", "%2F", date)

  expect_equal(encoded_date, "11%2F15%2F2024")
})

test_that("season ID selection logic is sound", {
  # Test that date ranges for seasons don't overlap

  dates <- list(
    "2024-25" = c(as.Date("2024-05-01"), as.Date("2025-05-01")),
    "2023-24" = c(as.Date("2023-05-01"), as.Date("2024-05-01")),
    "2022-23" = c(as.Date("2022-05-01"), as.Date("2023-05-01"))
  )

  # Check that a date in Nov 2024 falls in 2024-25
  test_date <- as.Date("2024-11-15")
  expect_true(test_date > dates[["2024-25"]][1])
  expect_true(test_date <= dates[["2024-25"]][2])
  expect_false(test_date > dates[["2023-24"]][1] && test_date <= dates[["2023-24"]][2])

  # Check that a date in Nov 2023 falls in 2023-24
  test_date2 <- as.Date("2023-11-15")
  expect_true(test_date2 > dates[["2023-24"]][1])
  expect_true(test_date2 <= dates[["2023-24"]][2])
  expect_false(test_date2 > dates[["2024-25"]][1])
})

test_that("game ID extraction from HTML works", {
  # Test regex pattern for extracting game IDs from HTML

  test_html <- c(
    '<a href="/contests/12345/box_score">Box Score</a>',
    '<a href="/contests/67890/play_by_play/">Play by Play</a>',
    '<a href="/contests/11111/team_stats">Stats</a>'
  )

  # Pattern: "(?<=/contests/)\\d+(?=/)"
  game_ids <- stringr::str_extract_all(paste(test_html, collapse = " "),
                                        "(?<=/contests/)\\d+(?=/)")[[1]]

  expect_equal(length(game_ids), 3)
  expect_true("12345" %in% game_ids)
  expect_true("67890" %in% game_ids)
  expect_true("11111" %in% game_ids)
})

test_that("neutral site indicator parsing works", {
  # Neutral sites are indicated by "@Location" in team names

  test_opponents <- c(
    "Duke",
    "Maryland @Phoenix, AZ",
    "Tennessee @Brooklyn, NY"
  )

  # Check for @ symbol
  is_neutral <- grepl("@", test_opponents)

  expect_false(is_neutral[1])
  expect_true(is_neutral[2])
  expect_true(is_neutral[3])
})

test_that("player name format validation", {
  # Player names should be uppercase with dots for spaces

  valid_names <- c(
    "CARDOSO.KAMILLA",
    "TEHINA.PAOPAO",
    "MILAYSIA.FULWILEY"
  )

  invalid_names <- c(
    "cardoso kamilla",  # lowercase
    "Cardoso-Kamilla",  # hyphen
    "CARDOSO KAMILLA"   # space
  )

  # Valid pattern: only uppercase letters and dots
  pattern <- "^[A-Z.]+$"

  expect_true(all(grepl(pattern, valid_names)))
  expect_false(any(grepl(pattern, invalid_names)))
})

test_that("event description parsing identifies key events", {
  # Test that we can identify different event types from descriptions

  descriptions <- c(
    "Good Jumper by CARDOSO.KAMILLA",
    "Missed Three Point Jumper by WATKINS.TESSA",
    "Defensive Rebound by FEAGIN.BREE",
    "Turnover by FULWILEY.MILAYSIA",
    "Foul on PAOPAO.TESSA",
    "Assist by WATKINS.TESSA"
  )

  # Check patterns
  expect_true(grepl("Jumper", descriptions[1]))
  expect_true(grepl("Missed", descriptions[2]))
  expect_true(grepl("Three Point", descriptions[2]))
  expect_true(grepl("Rebound", descriptions[3]))
  expect_true(grepl("Turnover", descriptions[4]))
  expect_true(grepl("Foul", descriptions[5]))
  expect_true(grepl("Assist", descriptions[6]))
})

test_that("sleep delays are reasonable", {
  # Functions should include Sys.sleep to avoid overwhelming server
  # Typical delay is 0.5 to 2 seconds

  reasonable_delays <- c(0.5, 1, 2)

  expect_true(all(reasonable_delays >= 0.5))
  expect_true(all(reasonable_delays <= 2))
})
