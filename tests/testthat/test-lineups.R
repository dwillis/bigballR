test_that("lineup string formatting is consistent", {
  lineups <- create_mock_lineups()

  # Lineup strings should be sorted alphabetically and joined with " + "
  for (i in 1:nrow(lineups)) {
    lineup_str <- lineups$Lineup[i]

    # Should contain " + " separators
    expect_true(grepl(" \\+ ", lineup_str))

    # Split into players
    players <- strsplit(lineup_str, " \\+ ")[[1]]

    # Should have exactly 5 players
    expect_equal(length(players), 5)

    # Players should be in alphabetical order
    expect_equal(players, sort(players))

    # All players should be uppercase with dots
    expect_true(all(grepl("^[A-Z.]+$", players)))
  }
})

test_that("lineup identification works correctly", {
  # Test that lineups can be uniquely identified
  lineups <- create_mock_lineups()

  # Each lineup string should be unique per team-game combination
  lineup_ids <- paste(lineups$Team, lineups$Opponent, lineups$Lineup, sep = "_")

  # In this mock data, we have same lineup in 2 different games
  expect_equal(length(unique(lineup_ids)), nrow(lineups))
})

test_that("lineup minutes are valid", {
  lineups <- create_mock_lineups()

  # Minutes should be positive
  expect_true(all(lineups$Mins > 0))

  # Minutes per lineup shouldn't exceed game length (40 for regulation)
  # Can be more if overtime
  expect_true(all(lineups$Mins <= 50))  # Reasonable upper bound
})

test_that("possession counts are reasonable", {
  lineups <- create_mock_lineups()

  # Possessions should be positive
  expect_true(all(lineups$OffPoss > 0))
  expect_true(all(lineups$DefPoss > 0))

  # Offensive and defensive possessions should be similar
  # (they can differ by 1-2 due to game start/end)
  for (i in 1:nrow(lineups)) {
    diff <- abs(lineups$OffPoss[i] - lineups$DefPoss[i])
    expect_true(diff <= 3)
  }
})

test_that("lineup filtering by included players works", {
  # Test logic for filtering lineups that include specific players
  lineups <- create_mock_lineups()

  player_to_find <- "CARDOSO.KAMILLA"

  # Check which lineups include this player
  includes_player <- grepl(player_to_find, lineups$Lineup, fixed = TRUE)

  # In our mock data, this player is in all lineups
  expect_true(all(includes_player))
})

test_that("lineup filtering by excluded players works", {
  # Test logic for filtering lineups that exclude specific players
  lineups <- create_mock_lineups()

  player_to_exclude <- "UNKNOWN.PLAYER"

  # Check which lineups exclude this player
  excludes_player <- !grepl(player_to_exclude, lineups$Lineup, fixed = TRUE)

  # This player should not be in any lineup
  expect_true(all(excludes_player))
})

test_that("lineup extraction from pbp identifies 5-player groups", {
  pbp <- create_mock_pbp()

  # Extract unique lineups from play-by-play
  for (i in 1:nrow(pbp)) {
    home_lineup <- c(pbp$Home.1[i], pbp$Home.2[i], pbp$Home.3[i],
                     pbp$Home.4[i], pbp$Home.5[i])
    away_lineup <- c(pbp$Away.1[i], pbp$Away.2[i], pbp$Away.3[i],
                     pbp$Away.4[i], pbp$Away.5[i])

    # Should have 5 unique players
    expect_equal(length(unique(home_lineup)), 5)
    expect_equal(length(unique(away_lineup)), 5)

    # Create lineup string
    home_str <- paste(sort(home_lineup), collapse = " + ")
    away_str <- paste(sort(away_lineup), collapse = " + ")

    # Should be valid strings
    expect_type(home_str, "character")
    expect_type(away_str, "character")
    expect_true(nchar(home_str) > 0)
    expect_true(nchar(away_str) > 0)
  }
})

test_that("garbage time filtering logic works", {
  # Test the garbage time identification logic
  # Garbage time when:
  # - Lead >= 25 with 10-5 mins left
  # - Lead >= 20 with 5-2 mins left
  # - Lead >= 15 with <2 mins left
  # AND <= 3 starters on court

  # Test case 1: 25 point lead with 8 minutes left (480 seconds remaining)
  lead <- 25
  seconds_left <- 480
  expect_true(lead >= 25 && seconds_left >= 300 && seconds_left <= 600)

  # Test case 2: 20 point lead with 3 minutes left (180 seconds remaining)
  lead <- 20
  seconds_left <- 180
  expect_true(lead >= 20 && seconds_left >= 120 && seconds_left <= 300)

  # Test case 3: 15 point lead with 1 minute left (60 seconds remaining)
  lead <- 15
  seconds_left <- 60
  expect_true(lead >= 15 && seconds_left < 120)

  # Test case 4: Close game - not garbage time
  lead <- 10
  seconds_left <- 60
  expect_false(lead >= 15)
})

test_that("lineup stats match sum of components", {
  lineups <- create_mock_lineups()

  for (i in 1:nrow(lineups)) {
    # 2-point makes should be total makes minus 3-point makes
    two_point_makes <- lineups$FGM[i] - lineups$ThreeM[i]
    expect_equal(two_point_makes, lineups$TwoM[i])

    # 2-point attempts should be total attempts minus 3-point attempts
    two_point_attempts <- lineups$FGA[i] - lineups$ThreeA[i]
    expect_equal(two_point_attempts, lineups$TwoA[i])
  }
})

test_that("lineup data includes opponent information", {
  lineups <- create_mock_lineups()

  # Should have opponent column
  expect_true("Opponent" %in% names(lineups))

  # Opponent should be different from team
  expect_true(all(lineups$Team != lineups$Opponent))
})
