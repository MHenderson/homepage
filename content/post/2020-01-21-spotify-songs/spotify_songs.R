
spotify_songs <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-01-21/spotify_songs.csv')

write_rds_bak(spotify_songs, here::here("content", "post", "2020-01-21-spotify-songs", "spotify_songs.rds"))
