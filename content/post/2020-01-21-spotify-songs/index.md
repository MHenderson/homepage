---
title: "(WIP) Tidy Tuesday: Spotify Songs"
description: "tt_load(2020, week = 4)"
author: Matthew Henderson
date: '2020-01-21'
slug: spotify-songs
categories:
  - posts
tags:
  - tidy-tuesday
editor_options: 
  chunk_output_type: console
draft: TRUE
---




```r
tuesdata <- tidytuesdayR::tt_load(2020, week = 4)
#> 
#> 	Downloading file 1 of 1: `spotify_songs.csv`

spotify_songs <- tuesdata$spotify_songs
```


```r
library(tidyverse)

spotify_songs %>%
  mutate(
    duration_s = duration_ms / 1000,
    duration_m = duration_s / 60
  ) %>%
  ggplot(aes(duration_m, colour = playlist_genre)) +
    geom_freqpoly() +
    labs(
            x = "duration (mins)",
            y = "",
        title = "Song length",
      caption = "data from Kaylin Pavlik"
    )
```

<img src="{{< blogdown/postref >}}index_files/figure-html/duration-1.png" width="672" />


```r
spotify_songs %>%
  pivot_longer(c("danceability", "energy")) %>%
  ggplot(aes(value, colour = playlist_genre)) +
    geom_freqpoly() +
    facet_wrap(~name) +
    labs(
            x = "",
            y = "",
        title = "Energy and danceability",
      caption = "data from Kaylin Pavlik"
    )
```

<img src="{{< blogdown/postref >}}index_files/figure-html/danceability-1.png" width="672" />


```r
spotify_songs %>%
  pivot_longer(c("speechiness","liveness")) %>%
  ggplot(aes(log(value), colour = playlist_genre)) +
    geom_freqpoly(binwidth = .1) +
    facet_wrap(~name, scales = "free") +
    labs(
            x = "",
            y = "",
        title = "",
      caption = "data from Kaylin Pavlik"
    )
```

<img src="{{< blogdown/postref >}}index_files/figure-html/speechiness-1.png" width="672" />


```r
spotify_songs %>%
  pivot_longer(c("acousticness","instrumentalness")) %>%
  ggplot(aes(log(value), colour = playlist_genre)) +
    geom_freqpoly(binwidth = .5) +
    facet_wrap(~name, scales = "free") +
    labs(
            x = "",
            y = "",
        title = "",
      caption = "data from Kaylin Pavlik"
    )
```

<img src="{{< blogdown/postref >}}index_files/figure-html/acousticness-1.png" width="672" />


```r
spotify_songs %>%
  pivot_longer(c("tempo")) %>%
  ggplot(aes(value, colour = playlist_genre)) +
    geom_freqpoly(binwidth = 1) +
    facet_wrap(~name, scales = "free") +
    labs(
            x = "",
            y = "",
        title = "",
      caption = "data from Kaylin Pavlik"
    )
```

<img src="{{< blogdown/postref >}}index_files/figure-html/tempo-1.png" width="672" />
