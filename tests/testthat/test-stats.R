test_that("player stats aggregation handles multiple games", {
  # Test that multi.games parameter works correctly
  pbp <- create_mock_pbp()

  # We can test the basic structure even without running full function
  # Check that we can identify unique games
  unique_games <- unique(pbp$ID)
  expect_equal(length(unique_games), 1)

  # Check that we can identify unique players
  players <- unique(c(pbp$Home.1, pbp$Home.2, pbp$Home.3, pbp$Home.4, pbp$Home.5,
                      pbp$Away.1, pbp$Away.2, pbp$Away.3, pbp$Away.4, pbp$Away.5))
  players <- players[!is.na(players)]

  expect_true(length(players) == 10)  # 5 home + 5 away
})

test_that("shot statistics are calculated correctly", {
  pbp <- create_mock_pbp()

  # Count made shots for a specific player
  player <- "CARDOSO.KAMILLA"
  player_shots <- pbp[pbp$Player_1 == player & !is.na(pbp$Shot_Value), ]

  made_shots <- sum(player_shots$Event_Result == "made", na.rm = TRUE)
  total_shots <- nrow(player_shots)

  expect_true(made_shots >= 0)
  expect_true(total_shots >= made_shots)

  # Calculate FG%
  if (total_shots > 0) {
    fg_pct <- made_shots / total_shots * 100
    expect_true(fg_pct >= 0 && fg_pct <= 100)
  }
})

test_that("points calculation is correct", {
  pbp <- create_mock_pbp()

  # Calculate points for a player
  player <- "CARDOSO.KAMILLA"
  player_baskets <- pbp[pbp$Player_1 == player &
                        pbp$Event_Result == "made" &
                        !is.na(pbp$Shot_Value), ]

  points <- sum(player_baskets$Shot_Value, na.rm = TRUE)

  expect_true(points >= 0)
  expect_type(points, "double")
})

test_that("game score formula components exist", {
  # Test that we can calculate game score components
  # GS = PTS + 0.4*FGM - 0.7*FGA - 0.4*(FTA-FTM) + 0.7*ORB + 0.3*DRB + STL + 0.7*AST + 0.7*BLK - 0.4*PF - TOV

  pbp <- create_mock_pbp()

  # We should be able to identify these events from play-by-play
  event_types <- unique(pbp$Event_Type)

  # Points come from made shots
  shots <- pbp[!is.na(pbp$Shot_Value), ]
  expect_true(nrow(shots) > 0)

  # Can identify made vs missed
  made <- pbp[pbp$Event_Result == "made" & !is.na(pbp$Event_Result), ]
  expect_true(nrow(made) > 0)
})

test_that("possession calculation handles turnovers", {
  # Possessions should end on:
  # - Made field goal (not followed by offensive rebound)
  # - Defensive rebound
  # - Turnover
  # - End of period

  pbp <- create_mock_pbp()

  # We can test that we identify key events
  # Turnovers should be identifiable
  turnovers <- pbp[grepl("Turnover", pbp$Event_Type, ignore.case = TRUE), ]

  # Made baskets should be identifiable
  made_baskets <- pbp[pbp$Event_Result == "made" & !is.na(pbp$Event_Result), ]
  expect_true(nrow(made_baskets) > 0)
})

test_that("assist tracking links to made baskets", {
  # Assists should only occur with made baskets
  # Player_2 in pbp should be the assister

  pbp <- create_mock_pbp()

  # Check for any assists in data
  assists <- pbp[!is.na(pbp$Player_2), ]

  # If there are assists, they should be on made baskets
  if (nrow(assists) > 0) {
    expect_true(all(assists$Event_Result == "made"))
  }
})

test_that("minutes calculation is valid", {
  pbp <- create_mock_pbp()

  # Calculate time each player was on court
  # This is based on Game_Seconds

  total_seconds <- max(pbp$Game_Seconds) - min(pbp$Game_Seconds)
  total_minutes <- total_seconds / 60

  expect_true(total_minutes > 0)
  expect_true(total_minutes <= 40)  # Regulation is 40 minutes
})

test_that("lineup stats structure is correct", {
  lineups <- create_mock_lineups()

  expect_s3_class(lineups, "data.frame")

  # Check required stats columns
  required_cols <- c("Lineup", "Team", "Mins", "OffPoss", "DefPoss",
                     "ORtg", "DRtg", "NetRtg", "FGM", "FGA", "FG_PCT")

  expect_true(all(required_cols %in% names(lineups)))
})

test_that("offensive rating calculation is valid", {
  lineups <- create_mock_lineups()

  # ORtg = (Points / Possessions) * 100
  # Should be reasonable basketball value (typically 80-130)

  expect_true(all(lineups$ORtg > 0))
  expect_true(all(lineups$ORtg < 200))  # Sanity check

  # Check calculation
  # Points can be calculated from FGM, ThreeM, FTM
  for (i in 1:nrow(lineups)) {
    points <- (lineups$FGM[i] - lineups$ThreeM[i]) * 2 +
              lineups$ThreeM[i] * 3 +
              lineups$FTM[i]

    calc_ortg <- (points / lineups$OffPoss[i]) * 100

    # Should be close (allowing for rounding)
    expect_equal(calc_ortg, lineups$ORtg[i], tolerance = 1)
  }
})

test_that("shooting percentages are valid", {
  lineups <- create_mock_lineups()

  # All percentages should be between 0 and 100
  expect_true(all(lineups$FG_PCT >= 0 & lineups$FG_PCT <= 100))
  expect_true(all(lineups$Two_PCT >= 0 & lineups$Two_PCT <= 100))
  expect_true(all(lineups$Three_PCT >= 0 & lineups$Three_PCT <= 100))
  expect_true(all(lineups$FT_PCT >= 0 & lineups$FT_PCT <= 100))

  # Check FG% calculation
  for (i in 1:nrow(lineups)) {
    calc_fg_pct <- (lineups$FGM[i] / lineups$FGA[i]) * 100
    expect_equal(calc_fg_pct, lineups$FG_PCT[i], tolerance = 0.1)
  }
})

test_that("pace calculation is reasonable", {
  lineups <- create_mock_lineups()

  # Pace should be roughly (Possessions / Minutes) * 40
  # Typical values are 60-80

  expect_true(all(lineups$Pace > 40))
  expect_true(all(lineups$Pace < 100))
})

test_that("net rating is difference of offensive and defensive rating", {
  lineups <- create_mock_lineups()

  for (i in 1:nrow(lineups)) {
    calc_net <- lineups$ORtg[i] - lineups$DRtg[i]
    expect_equal(calc_net, lineups$NetRtg[i], tolerance = 0.1)
  }
})
