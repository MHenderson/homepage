---
title: "(WIP) Tidy Tuesday: Replicating Plots in R"
description: "tt_load(2019, week = 51)"
author: Matthew Henderson
date: '2019-12-10'
slug: replicating-plots-in-r
categories:
  - posts
tags:
  - tidy-tuesday
editor_options: 
  chunk_output_type: console
draft: true
---




```r
tuesdata <- tidytuesdayR::tt_load(2019, week = 50)
#> 
#> 	Downloading file 1 of 4: `diseases.csv`
#> 	Downloading file 2 of 4: `gun_murders.csv`
#> 	Downloading file 3 of 4: `international_murders.csv`
#> 	Downloading file 4 of 4: `nyc_regents.csv`
```

## G8 Homicide


```r
library(tidyverse)

tuesdata$gun_murders %>%
  mutate(
    country = reorder(country, count)
  ) %>%
  ggplot(aes(country, count)) +
    geom_point() +
    labs(
         title = "Homicide in the G8",
      subtitle = "Rates of homicide in G8 member countries.",
       caption = "source: United Nations Office on Drugs and Crime",
             x = "",
             y = "Gun-related homicides\nper 100,000 people"
    ) +
    coord_flip()
```

<img src="{{< blogdown/postref >}}index_files/figure-html/murders-cover-1.png" width="768" />

## Diseases


```r
tuesdata$diseases %>%
  filter(disease == "Measles") %>%
  mutate(rate = count / population * 10000 * 52 / weeks_reporting) %>%
  mutate(state = reorder(state, desc(state))) %>%
  ggplot(aes(year, state, fill = rate)) +
  geom_tile(color = "white", size = 0.35) +
  scale_x_continuous(expand = c(0,0)) +
  scale_fill_gradient(
         low = "azure2",
        high = "darkslategrey",
    na.value = 'white'
  ) +
  labs(
           x = "",
           y = "",
       title = "Battling Measles in the 20th Century",
    subtitle = "The Impact of Vaccines",
     caption = ""
  )
```

<img src="{{< blogdown/postref >}}index_files/figure-html/diseases-1.png" width="768" />
