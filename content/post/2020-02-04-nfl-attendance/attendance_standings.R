attendance <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-02-04/attendance.csv')
standings <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-02-04/standings.csv')

attendance_standings <- dplyr::left_join(attendance, standings, by = c("year", "team_name", "team"))

write_rds_bak(attendance_standings, here::here("content", "post", "2020-02-04-nfl-attendance", "attendance_standings.rds"))
