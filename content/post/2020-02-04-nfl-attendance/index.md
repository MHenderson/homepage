---
title: "(WIP) Tidy Tuesday: NFL Attendance" 
author: Matthew Henderson
description: "tt_load(2020, week = 6)"
date: '2020-02-04'
slug: nfl-attendance
categories:
  - posts
tags:
  - tidy-tuesday
editor_options: 
  chunk_output_type: console
draft: TRUE
---




```r
library(tidytuesdayR)

tuesdata <- tt_load(2020, week = 6)
#> 
#> 	Downloading file 1 of 3: `attendance.csv`
#> 	Downloading file 2 of 3: `games.csv`
#> 	Downloading file 3 of 3: `standings.csv`
```


```r
library(tidyverse)

tuesdata$attendance %>%
  left_join(tuesdata$standings, by = c("year", "team_name", "team")) %>%
  mutate(team = paste(team, team_name)) %>%
  filter(year==2003) %>%
  ggplot(aes(week, weekly_attendance)) +
  geom_step() +
  geom_smooth() +
  facet_wrap(~team)
```

<img src="{{< blogdown/postref >}}index_files/figure-html/duration-1.png" width="1440" />
