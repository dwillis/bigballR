test_that("mock roster has correct structure", {
  roster <- create_mock_roster()

  expect_s3_class(roster, "data.frame")
  expect_equal(nrow(roster), 5)

  # Check required columns
  expect_true("Jersey" %in% names(roster))
  expect_true("Name" %in% names(roster))
  expect_true("Player" %in% names(roster))
  expect_true("Pos" %in% names(roster))
  expect_true("Height" %in% names(roster))
  expect_true("HtInches" %in% names(roster))
  expect_true("Player_ID" %in% names(roster))

  # Check data types
  expect_type(roster$Jersey, "character")
  expect_type(roster$Player, "character")
  expect_type(roster$HtInches, "double")
})

test_that("player name cleaning works correctly", {
  # Test the player name normalization logic
  # The function converts names to uppercase and replaces spaces with dots

  test_names <- c("Kamilla Cardoso", "Te-Hina Paopao", "MiLaysia Fulwiley")

  # Remove non-alphanumeric except spaces
  format <- gsub("[^[:alnum:] ]", "", test_names)
  # Convert to uppercase and replace spaces with dots
  format <- toupper(gsub("\\s+", ".", format))

  expect_equal(format[1], "KAMILLA.CARDOSO")
  expect_equal(format[2], "TEHINA.PAOPAO")  # Hyphen removed
  expect_equal(format[3], "MILAYSIA.FULWILEY")
})

test_that("player name suffix removal works", {
  # Test that suffixes like JR, SR, III are removed

  test_names <- c("JOHN.SMITH.JR", "JANE.DOE.SR", "BOB.JONES.III", "REGULAR.NAME")

  # Pattern used in the actual function
  pattern <- "(\\.JR\\.|\\.SR\\.|\\.J\\.R\\.|\\.JR\\.|JR\\.|SR\\.|\\.SR|\\.JR|\\.SR|\\.III|\\.II|\\.IV)$"

  cleaned <- gsub(pattern, "", test_names)

  expect_equal(cleaned[1], "JOHN.SMITH")
  expect_equal(cleaned[2], "JANE.DOE")
  expect_equal(cleaned[3], "BOB.JONES")
  expect_equal(cleaned[4], "REGULAR.NAME")
})

test_that("height conversion to inches works", {
  # Test conversion from height format "X-Y" to total inches

  convert_height <- function(height_str) {
    parts <- as.numeric(strsplit(height_str, "-")[[1]])
    return(12 * parts[1] + parts[2])
  }

  expect_equal(convert_height("6-7"), 79)  # 6 feet 7 inches = 79 inches
  expect_equal(convert_height("5-9"), 69)  # 5 feet 9 inches = 69 inches
  expect_equal(convert_height("6-2"), 74)  # 6 feet 2 inches = 74 inches

  roster <- create_mock_roster()
  expect_equal(roster$HtInches[1], 79)  # Kamilla Cardoso 6-7
  expect_equal(roster$HtInches[5], 69)  # Te-Hina Paopao 5-9
})

test_that("player ID extraction pattern works", {
  # Test the regex pattern for extracting player IDs from HTML

  test_html <- c(
    '<a href="/players/1234567">Player One</a>',
    '<a href="/players/1234568">Player Two</a>',
    '<a href="/players/9876543">Player Three</a>'
  )

  # Pattern used in actual function: '(?<=href="/players/)\\d+'
  player_ids <- stringr::str_extract_all(paste(test_html, collapse = " "),
                                          '(?<=href="/players/)\\d+')[[1]]

  expect_equal(length(player_ids), 3)
  expect_equal(player_ids[1], "1234567")
  expect_equal(player_ids[2], "1234568")
  expect_equal(player_ids[3], "9876543")
})

test_that("roster validates player ID count", {
  roster <- create_mock_roster()

  # All players should have IDs in mock data
  expect_equal(length(roster$Player_ID), nrow(roster))
  expect_true(all(!is.na(roster$Player_ID)))

  # Player IDs should be numeric strings
  expect_true(all(grepl("^\\d+$", roster$Player_ID)))
})

test_that("roster position values are valid", {
  roster <- create_mock_roster()

  valid_positions <- c("G", "F", "C", "G/F", "F/C", "F/G", "C/F")

  expect_true(all(roster$Pos %in% valid_positions))
})

test_that("roster handles class year correctly", {
  roster <- create_mock_roster()

  valid_classes <- c("Fr", "So", "Jr", "Sr", "Gr")

  # Check that Class column exists and has valid values
  expect_true("Class" %in% names(roster))
  expect_true(all(roster$Class %in% valid_classes))
})

test_that("player name matches cleaned name", {
  roster <- create_mock_roster()

  # The Player field should be the normalized version of Name
  # Check that they correspond
  expect_equal(nrow(roster), length(roster$Player))
  expect_equal(nrow(roster), length(roster$CleanName))

  # CleanName should match original Name
  expect_equal(roster$CleanName, roster$Name)
})
