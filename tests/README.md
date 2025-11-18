# bigballR Test Suite

This directory contains the test suite for the bigballR package, adapted for NCAA Women's Basketball.

## Running Tests

To run all tests:

```r
# Install devtools and testthat if needed
install.packages(c("devtools", "testthat"))

# Load the package
devtools::load_all()

# Run all tests
devtools::test()

# Or use testthat directly
testthat::test_dir("tests/testthat")
```

To run a specific test file:

```r
testthat::test_file("tests/testthat/test-roster.R")
```

## Test Structure

The test suite is organized into the following files:

### Core Functionality Tests

- **test-schedule.R**: Tests for `get_date_games()` and `get_team_schedule()`
  - Season ID mapping for WBB
  - Conference name handling
  - Date formatting and parsing
  - Team record extraction
  - Neutral site detection

- **test-roster.R**: Tests for `get_team_roster()`
  - Player name cleaning and normalization
  - Height conversion to inches
  - Player ID extraction from HTML
  - Position and class validation
  - Name suffix removal (Jr, Sr, III)

- **test-pbp.R**: Tests for `scrape_game()` and `get_play_by_play()`
  - Play-by-play data structure validation
  - Game time tracking
  - Score monotonicity
  - Event type validation
  - Lineup tracking (5 players per team)
  - Player-on-court verification
  - Substitution tracking

### Statistical Analysis Tests

- **test-stats.R**: Tests for `get_player_stats()` and statistical calculations
  - Shot statistics (FG%, 2P%, 3P%, FT%)
  - Points calculation
  - Game Score formula components
  - Possession calculation
  - Assist tracking
  - Minutes calculation
  - Offensive and defensive rating
  - Pace calculation

- **test-lineups.R**: Tests for `get_lineups()` and lineup analysis
  - Lineup string formatting
  - Lineup identification
  - Minutes validation
  - Possession counts
  - Player filtering (included/excluded)
  - Garbage time filtering logic
  - Lineup component aggregation

### Utility Tests

- **test-utils.R**: Tests for helper functions and utilities
  - Conference ID mapping
  - Team name cleaning
  - URL construction
  - Date encoding for URLs
  - Season ID date ranges
  - Game ID extraction from HTML
  - Neutral site parsing
  - Player name format validation
  - Event description parsing

### Test Fixtures

- **helper-fixtures.R**: Mock data and helper functions
  - `create_mock_pbp()`: Generates sample play-by-play data
  - `create_mock_schedule()`: Generates sample schedule data
  - `create_mock_roster()`: Generates sample roster data
  - `create_mock_lineups()`: Generates sample lineup data
  - `create_mock_game_html()`: Generates sample HTML for parsing

## Test Coverage

The test suite covers:

1. **Data Retrieval Functions**
   - Schedule scraping
   - Roster scraping
   - Play-by-play scraping
   - Game ID extraction

2. **Data Validation**
   - Structure validation
   - Data type checking
   - Range checking
   - Required field verification

3. **String Processing**
   - Name normalization
   - Pattern matching (regex)
   - HTML parsing
   - URL encoding

4. **Statistical Calculations**
   - Shooting percentages
   - Rating calculations (ORtg, DRtg, NetRtg)
   - Possession counting
   - Minutes tracking

5. **Edge Cases**
   - Missing data handling
   - Overtime games
   - Substitution errors
   - Cancelled games
   - Neutral site games

## Mock Data

Tests use mock data fixtures to avoid requiring live internet access to stats.ncaa.org. This makes tests:

- **Fast**: No network latency
- **Reliable**: Not dependent on external service availability
- **Deterministic**: Same results every time
- **Safe**: No risk of overwhelming NCAA servers

Mock data is designed to be realistic and cover common scenarios in women's basketball games.

## Test Patterns

### Testing Without Live Data

Since the package scrapes live data from stats.ncaa.org, many tests focus on:

1. **Data structure validation**: Ensuring returned data frames have correct columns and types
2. **Logic validation**: Testing parsing, calculation, and filtering logic
3. **Pattern matching**: Verifying regex patterns work correctly
4. **Edge case handling**: Testing error conditions and special cases

### Example Test Pattern

```r
test_that("player name cleaning works correctly", {
  # Test the player name normalization logic
  test_names <- c("Kamilla Cardoso", "Te-Hina Paopao")

  # Apply normalization
  format <- gsub("[^[:alnum:] ]", "", test_names)
  format <- toupper(gsub("\\s+", ".", format))

  # Verify results
  expect_equal(format[1], "KAMILLA.CARDOSO")
  expect_equal(format[2], "TEHINA.PAOPAO")
})
```

## Adding New Tests

When adding new tests:

1. Create tests in the appropriate test file or create a new one following the naming convention `test-*.R`
2. Use descriptive test names that explain what is being tested
3. Include both positive and negative test cases
4. Add mock data to `helper-fixtures.R` if needed
5. Document any assumptions or dependencies
6. Ensure tests are independent and can run in any order

### Test Naming Convention

```r
test_that("function does what when condition", {
  # Test code
})
```

Examples:
- `test_that("roster validates player ID count", { ... })`
- `test_that("lineup filtering by included players works", { ... })`
- `test_that("shot statistics are calculated correctly", { ... })`

## Continuous Testing

During development, you can run tests automatically on file changes using:

```r
testthat::auto_test("R", "tests/testthat")
```

## Test Results

All tests should pass with the current codebase. If tests fail:

1. Check that all package dependencies are installed
2. Verify you're using the correct version of R (>= 3.1.2)
3. Ensure the package is loaded with `devtools::load_all()`
4. Check for any recent changes to the functions being tested

## WBB-Specific Tests

Several tests are specific to the Women's Basketball adaptation:

- Season ID ranges for WBB (different from MBB)
- Player ID extraction from roster pages
- Conference mappings (same for both, but verified)
- URL patterns for WBB data

## Future Test Additions

Potential areas for future test expansion:

1. Integration tests with cached real data
2. Performance benchmarks
3. Visualization function tests (plot_mins_dist, plot_duos)
4. Box score parsing tests
5. Possession calculation tests
6. On/off analysis tests
7. Error handling and recovery tests

## Contributing

When contributing new features:

1. Add corresponding tests
2. Ensure all existing tests still pass
3. Update this README if adding new test files
4. Add mock data fixtures if needed
