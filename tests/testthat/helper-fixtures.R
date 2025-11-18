# Helper functions and fixtures for tests

# Create a minimal mock play-by-play dataframe for testing
create_mock_pbp <- function() {
  data.frame(
    ID = rep(12345, 10),
    Date = rep("2024-11-15", 10),
    Home = rep("South Carolina", 10),
    Away = rep("Maryland", 10),
    Time = c("20:00", "19:45", "19:30", "19:15", "19:00",
             "18:45", "18:30", "18:15", "18:00", "17:45"),
    Game_Time = c("00:00", "00:15", "00:30", "00:45", "01:00",
                  "01:15", "01:30", "01:45", "02:00", "02:15"),
    Game_Seconds = seq(0, 135, 15),
    Half_Status = rep(1, 10),
    Home_Score = c(0, 2, 2, 4, 4, 6, 8, 8, 10, 10),
    Away_Score = c(0, 0, 2, 2, 4, 4, 4, 6, 6, 8),
    Event_Team = c("South Carolina", "South Carolina", "Maryland", "South Carolina",
                   "Maryland", "South Carolina", "South Carolina", "Maryland",
                   "South Carolina", "Maryland"),
    Event_Description = c("Jump Ball won by South Carolina",
                          "Good Jumper by CARDOSO.KAMILLA",
                          "Good Layup by SMITH.SHYANNE",
                          "Good Jumper by WATKINS.TESSA",
                          "Good Layup by JOHNSON.KAELYNN",
                          "Good Layup by CARDOSO.KAMILLA",
                          "Good Layup by FEAGIN.BREE",
                          "Good Jumper by SMITH.SHYANNE",
                          "Good Layup by CARDOSO.KAMILLA",
                          "Good Jumper by JOHNSON.KAELYNN"),
    Player_1 = c("CARDOSO.KAMILLA", "CARDOSO.KAMILLA", "SMITH.SHYANNE",
                 "WATKINS.TESSA", "JOHNSON.KAELYNN", "CARDOSO.KAMILLA",
                 "FEAGIN.BREE", "SMITH.SHYANNE", "CARDOSO.KAMILLA", "JOHNSON.KAELYNN"),
    Player_2 = rep(NA, 10),
    Event_Type = c("Jump Ball", "Jumper", "Layup", "Jumper", "Layup",
                   "Layup", "Layup", "Jumper", "Layup", "Jumper"),
    Event_Result = c(NA, "made", "made", "made", "made",
                     "made", "made", "made", "made", "made"),
    Shot_Value = c(NA, 2, 2, 2, 2, 2, 2, 2, 2, 2),
    Event_Length = c(0, 15, 15, 15, 15, 15, 15, 15, 15, 15),
    Home.1 = rep("CARDOSO.KAMILLA", 10),
    Home.2 = rep("WATKINS.TESSA", 10),
    Home.3 = rep("FEAGIN.BREE", 10),
    Home.4 = rep("FULWILEY.MILAYSIA", 10),
    Home.5 = rep("PAOPAO.TESSA", 10),
    Away.1 = rep("SMITH.SHYANNE", 10),
    Away.2 = rep("JOHNSON.KAELYNN", 10),
    Away.3 = rep("REESE.CHRISTINA", 10),
    Away.4 = rep("MILLER.SAYLOR", 10),
    Away.5 = rep("SMIKLE.ALLIE", 10),
    Status = rep("CLEAN", 10),
    Sub_Deviate = rep(0, 10),
    stringsAsFactors = FALSE
  )
}

# Create mock schedule data
create_mock_schedule <- function() {
  data.frame(
    Date = c("11/01/2024", "11/05/2024", "11/08/2024"),
    Start_Time = c("7:00 PM", "6:00 PM", "8:00 PM"),
    Home = c("South Carolina", "Tennessee", "South Carolina"),
    Away = c("Maryland", "South Carolina", "Duke"),
    BoxID = c(5001, 5002, 5003),
    GameID = c(5001, 5002, 5003),
    Home_Score = c(78, 65, 82),
    Away_Score = c(65, 70, 68),
    Attendance = c(18000, 21000, 17500),
    Neutral_Site = c(FALSE, FALSE, FALSE),
    Home_Wins = c(1, 0, 2),
    Home_Losses = c(0, 1, 0),
    Away_Wins = c(0, 1, 1),
    Away_Losses = c(1, 1, 1),
    stringsAsFactors = FALSE
  )
}

# Create mock roster data
create_mock_roster <- function() {
  data.frame(
    Jersey = c("1", "2", "3", "4", "5"),
    Name = c("Kamilla Cardoso", "Tessa Watkins", "Bree Feagin",
             "MiLaysia Fulwiley", "Te-Hina Paopao"),
    Pos = c("C", "F", "G", "G", "G"),
    Height = c("6-7", "6-2", "5-10", "5-9", "5-9"),
    Class = c("Jr", "Jr", "Sr", "Fr", "Gr"),
    Hometown = c("Brazil", "SC", "GA", "SC", "HI"),
    `High School` = rep("", 5),
    `Previous School` = c("", "", "", "", "Oregon"),
    GP = c(35, 35, 35, 35, 35),
    Player = c("KAMILLA.CARDOSO", "TESSA.WATKINS", "BREE.FEAGIN",
               "MILAYSIA.FULWILEY", "TEHINA.PAOPAO"),
    CleanName = c("Kamilla Cardoso", "Tessa Watkins", "Bree Feagin",
                  "MiLaysia Fulwiley", "Te-Hina Paopao"),
    HtInches = c(79, 74, 70, 69, 69),
    Player_ID = c("1234567", "1234568", "1234569", "1234570", "1234571"),
    stringsAsFactors = FALSE,
    check.names = FALSE
  )
}

# Create mock lineup data
create_mock_lineups <- function() {
  data.frame(
    Lineup = c("CARDOSO.KAMILLA + FEAGIN.BREE + FULWILEY.MILAYSIA + PAOPAO.TESSA + WATKINS.TESSA",
               "CARDOSO.KAMILLA + FEAGIN.BREE + FULWILEY.MILAYSIA + PAOPAO.TESSA + WATKINS.TESSA"),
    Team = c("South Carolina", "South Carolina"),
    Opponent = c("Maryland", "Duke"),
    Mins = c(25.5, 22.3),
    OffPoss = c(45, 40),
    DefPoss = c(44, 39),
    ORtg = c(112.2, 108.5),
    DRtg = c(98.3, 102.1),
    NetRtg = c(13.9, 6.4),
    Pace = c(72.5, 70.2),
    FGM = c(18, 16),
    FGA = c(35, 33),
    FG_PCT = c(51.4, 48.5),
    TwoM = c(14, 13),
    TwoA = c(25, 24),
    Two_PCT = c(56.0, 54.2),
    ThreeM = c(4, 3),
    ThreeA = c(10, 9),
    Three_PCT = c(40.0, 33.3),
    FTM = c(12, 10),
    FTA = c(15, 13),
    FT_PCT = c(80.0, 76.9),
    AST = c(12, 10),
    TOV = c(8, 7),
    STL = c(6, 5),
    BLK = c(4, 3),
    PF = c(12, 11),
    stringsAsFactors = FALSE
  )
}

# Mock HTML for testing HTML parsing
create_mock_game_html <- function() {
  c(
    '<html>',
    '<body>',
    '<table>',
    '<tr><td>South Carolina</td><td>78</td></tr>',
    '<tr><td>Maryland</td><td>65</td></tr>',
    '</table>',
    '<table><tr><td></td></tr></table>',
    '<table><tr><td></td></tr></table>',
    '<table>',
    '<tr><td>Time</td><td>Away</td><td>Score</td><td>Home</td><td>Score</td></tr>',
    '<tr><td>20:00</td><td></td><td>0-0</td><td>Jump Ball won by South Carolina</td><td></td></tr>',
    '<tr><td>19:45</td><td></td><td>2-0</td><td>Good Jumper by CARDOSO.KAMILLA</td><td></td></tr>',
    '</table>',
    '</body>',
    '</html>'
  )
}
