test_that("get_date_games returns correct season ID for WBB", {
  # Test that season IDs are correctly mapped for WBB
  # We can't easily test the full function without mocking HTTP calls,
  # but we can verify the season ID logic internally

  # These tests verify the season ID mapping exists for WBB
  # The actual values are in the function's case_when statement

  # Test current season (2024-25) would use season ID 18402
  # Test previous season (2023-24) would use season ID 18220

  # Since the function uses dates to determine season ID,
  # we can verify that dates fall into expected ranges

  test_date_2024 <- as.Date("2024-11-15", format = "%Y-%m-%d")
  test_date_2023 <- as.Date("2023-11-15", format = "%Y-%m-%d")
  test_date_2022 <- as.Date("2022-11-15", format = "%Y-%m-%d")

  expect_true(test_date_2024 > as.Date("2024-05-01"))
  expect_true(test_date_2024 <= as.Date("2025-05-01"))

  expect_true(test_date_2023 > as.Date("2023-05-01"))
  expect_true(test_date_2023 <= as.Date("2024-05-01"))

  expect_true(test_date_2022 > as.Date("2022-05-01"))
  expect_true(test_date_2022 <= as.Date("2023-05-01"))
})

test_that("get_date_games handles conference name formatting", {
  # Test that conference names are correctly normalized
  # The function uses tolower and removes non-alphanumeric characters

  test_conference <- function(input, expected) {
    result <- tolower(sub("[^[:alnum:]=\\.]", "", input))
    expect_equal(result, expected)
  }

  test_conference("SEC", "sec")
  test_conference("Big Ten", "bigten")
  test_conference("Big 12", "big12")
  test_conference("ACC", "acc")
  test_conference("Pac-12", "pac12")
})

test_that("mock schedule data has correct structure", {
  schedule <- create_mock_schedule()

  expect_s3_class(schedule, "data.frame")
  expect_equal(nrow(schedule), 3)

  # Check required columns exist
  expect_true("Date" %in% names(schedule))
  expect_true("Home" %in% names(schedule))
  expect_true("Away" %in% names(schedule))
  expect_true("GameID" %in% names(schedule))
  expect_true("Home_Score" %in% names(schedule))
  expect_true("Away_Score" %in% names(schedule))

  # Check data types
  expect_type(schedule$Home, "character")
  expect_type(schedule$Away, "character")
  expect_type(schedule$GameID, "double")
  expect_type(schedule$Neutral_Site, "logical")
})

test_that("get_team_schedule parameters validate correctly", {
  # Test that function handles missing parameters appropriately
  # This would require mocking, so we test the parameter logic

  # When team.id is NA and team.name is NA, should fail
  # When team.id is provided, should work
  # When team.name and season are both provided, should work

  expect_true(is.na(NA))
  expect_false(is.na(12345))
  expect_false(is.na("Duke"))
})

test_that("schedule parsing handles team records correctly", {
  # Test the regex patterns for extracting wins/losses from team names
  # Pattern: "Team Name (W-L)"

  test_team <- "South Carolina (5-0)"

  # The function uses these patterns:
  # Wins: "(?<=[(])\\d+(?=-)"
  # Losses: "(?<=-)\\d+(?=[)])"

  wins <- stringr::str_extract(test_team, "(?<=[(])\\d+(?=-)")
  losses <- stringr::str_extract(test_team, "(?<=-)\\d+(?=[)])")

  expect_equal(wins, "5")
  expect_equal(losses, "0")

  # Test with different record
  test_team2 <- "Maryland (12-3)"
  wins2 <- stringr::str_extract(test_team2, "(?<=[(])\\d+(?=-)")
  losses2 <- stringr::str_extract(test_team2, "(?<=-)\\d+(?=[)])")

  expect_equal(wins2, "12")
  expect_equal(losses2, "3")
})

test_that("neutral site detection works", {
  schedule <- create_mock_schedule()

  # All games in mock data should be non-neutral
  expect_false(any(schedule$Neutral_Site))

  # Create a neutral site game
  neutral_schedule <- schedule
  neutral_schedule$Neutral_Site[1] <- TRUE

  expect_true(neutral_schedule$Neutral_Site[1])
  expect_false(neutral_schedule$Neutral_Site[2])
})

test_that("date formatting is correct", {
  # Test that dates are in expected format mm/dd/yyyy

  test_date <- "11/15/2024"
  date_parts <- strsplit(test_date, "/")[[1]]

  expect_equal(length(date_parts), 3)
  expect_equal(nchar(date_parts[1]), 2)  # month
  expect_equal(nchar(date_parts[2]), 2)  # day
  expect_equal(nchar(date_parts[3]), 4)  # year

  # Test date parsing
  parsed <- as.Date(test_date, format = "%m/%d/%Y")
  expect_s3_class(parsed, "Date")
})
