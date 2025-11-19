test_that("mock play-by-play has correct structure", {
  pbp <- create_mock_pbp()

  expect_s3_class(pbp, "data.frame")
  expect_equal(nrow(pbp), 10)

  # Check required columns exist
  required_cols <- c("ID", "Date", "Home", "Away", "Game_Time", "Game_Seconds",
                     "Home_Score", "Away_Score", "Event_Team", "Event_Description",
                     "Player_1", "Event_Type", "Event_Result", "Shot_Value",
                     "Home.1", "Home.2", "Home.3", "Home.4", "Home.5",
                     "Away.1", "Away.2", "Away.3", "Away.4", "Away.5",
                     "Status", "Sub_Deviate")

  expect_true(all(required_cols %in% names(pbp)))
})

test_that("game time parsing works correctly", {
  pbp <- create_mock_pbp()

  # Game_Seconds should increase monotonically
  expect_true(all(diff(pbp$Game_Seconds) >= 0))

  # First event should be at 0 seconds
  expect_equal(pbp$Game_Seconds[1], 0)

  # Game_Seconds should match the time elapsed
  expect_equal(pbp$Game_Seconds[10], 135)  # 2:15 = 135 seconds
})

test_that("score tracking is monotonic", {
  pbp <- create_mock_pbp()

  # Scores should never decrease
  expect_true(all(diff(pbp$Home_Score) >= 0))
  expect_true(all(diff(pbp$Away_Score) >= 0))

  # Final scores should be sum of baskets
  # Each made basket in mock data is worth 2 points
  home_baskets <- sum(pbp$Event_Team == "South Carolina" &
                      pbp$Event_Result == "made" &
                      !is.na(pbp$Shot_Value))
  away_baskets <- sum(pbp$Event_Team == "Maryland" &
                      pbp$Event_Result == "made" &
                      !is.na(pbp$Shot_Value))

  expect_equal(pbp$Home_Score[nrow(pbp)], home_baskets * 2)
  expect_equal(pbp$Away_Score[nrow(pbp)], away_baskets * 2)
})

test_that("event types are valid", {
  pbp <- create_mock_pbp()

  valid_events <- c("Jump Ball", "Jumper", "Layup", "Three Point Jumper",
                    "Free Throw", "Turnover", "Foul", "Rebound",
                    "Steal", "Block", "Assist", "Timeout",
                    "Enters Game", "Leaves Game")

  # All event types should be recognized
  expect_true(all(pbp$Event_Type %in% valid_events))
})

test_that("shot values are correct", {
  pbp <- create_mock_pbp()

  # Filter to only shot attempts
  shots <- pbp[!is.na(pbp$Shot_Value), ]

  # Shot values should be 1, 2, or 3
  expect_true(all(shots$Shot_Value %in% c(1, 2, 3)))

  # Jumpers and Layups should be 2 points
  jumpers <- pbp[pbp$Event_Type %in% c("Jumper", "Layup") & !is.na(pbp$Shot_Value), ]
  expect_true(all(jumpers$Shot_Value == 2))
})

test_that("lineup tracking has 5 players per team", {
  pbp <- create_mock_pbp()

  # Check that each row has 5 home players and 5 away players
  for (i in 1:nrow(pbp)) {
    home_players <- c(pbp$Home.1[i], pbp$Home.2[i], pbp$Home.3[i],
                      pbp$Home.4[i], pbp$Home.5[i])
    away_players <- c(pbp$Away.1[i], pbp$Away.2[i], pbp$Away.3[i],
                      pbp$Away.4[i], pbp$Away.5[i])

    # All should be non-NA
    expect_true(all(!is.na(home_players)))
    expect_true(all(!is.na(away_players)))

    # Should be unique (no player listed twice)
    expect_equal(length(unique(home_players)), 5)
    expect_equal(length(unique(away_players)), 5)
  }
})

test_that("player involved in event should be on court", {
  pbp <- create_mock_pbp()

  for (i in 1:nrow(pbp)) {
    player <- pbp$Player_1[i]

    if (!is.na(player)) {
      on_court <- c(pbp$Home.1[i], pbp$Home.2[i], pbp$Home.3[i],
                    pbp$Home.4[i], pbp$Home.5[i],
                    pbp$Away.1[i], pbp$Away.2[i], pbp$Away.3[i],
                    pbp$Away.4[i], pbp$Away.5[i])

      expect_true(player %in% on_court,
                  info = paste("Player", player, "not found on court at row", i))
    }
  }
})

test_that("status field is populated", {
  pbp <- create_mock_pbp()

  # Status should exist for all rows
  expect_true(all(!is.na(pbp$Status)))

  # Valid status values
  valid_status <- c("CLEAN", "DIRTY", "SUBSTITUTION ERROR")

  # In mock data, all should be CLEAN
  expect_true(all(pbp$Status == "CLEAN"))
})

test_that("substitution deviation tracking works", {
  pbp <- create_mock_pbp()

  # Sub_Deviate should be numeric
  expect_type(pbp$Sub_Deviate, "double")

  # Should be non-negative
  expect_true(all(pbp$Sub_Deviate >= 0))

  # In clean mock data, should all be 0
  expect_true(all(pbp$Sub_Deviate == 0))
})

test_that("event team matches player team", {
  pbp <- create_mock_pbp()

  for (i in 1:nrow(pbp)) {
    player <- pbp$Player_1[i]
    event_team <- pbp$Event_Team[i]

    if (!is.na(player) && event_team != "") {
      home_players <- c(pbp$Home.1[i], pbp$Home.2[i], pbp$Home.3[i],
                        pbp$Home.4[i], pbp$Home.5[i])
      away_players <- c(pbp$Away.1[i], pbp$Away.2[i], pbp$Away.3[i],
                        pbp$Away.4[i], pbp$Away.5[i])

      if (player %in% home_players) {
        expect_equal(event_team, pbp$Home[i])
      } else if (player %in% away_players) {
        expect_equal(event_team, pbp$Away[i])
      }
    }
  }
})

test_that("game ID is consistent throughout", {
  pbp <- create_mock_pbp()

  # All rows should have same game ID
  expect_equal(length(unique(pbp$ID)), 1)

  # ID should be numeric
  expect_type(pbp$ID, "double")
})

test_that("half status is valid", {
  pbp <- create_mock_pbp()

  # Half_Status should be 1 or 2 for regulation, 3+ for overtime
  expect_true(all(pbp$Half_Status >= 1))

  # In first half mock data, should all be 1
  expect_true(all(pbp$Half_Status == 1))
})
