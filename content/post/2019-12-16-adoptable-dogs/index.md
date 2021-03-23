---
title: "(WIP) Tidy Tuesday: Adoptable Dogs"
description: "tt_load(2019, week = 51)"
author: Matthew Henderson
date: '2019-12-16'
slug: adoptable-dogs
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

tuesdata <- tt_load(2019, week = 51)
#> 
#> 	Downloading file 1 of 3: `dog_descriptions.csv`
#> 	Downloading file 2 of 3: `dog_moves.csv`
#> 	Downloading file 3 of 3: `dog_travel.csv`
```


```r
library(tidyverse)

tuesdata$dog_descriptions %>%
  mutate(
    name = tolower(name)
  ) %>% 
  group_by(name) %>%
  count() %>%
  arrange(desc(n)) %>%
  head(50) %>%
  ggplot(aes(reorder(name, n), n)) +
    geom_text(aes(label = name)) +
    coord_flip() +
    labs(
      x = "",
      y = ""
    ) +
    ylim(50, 300) +
    theme(
      axis.text.y = element_blank(),
      panel.grid.major.y = element_blank()
    )
```

<img src="{{< blogdown/postref >}}index_files/figure-html/names-1.png" width="768" />


```r
library(statebins)
library(viridis)

tuesdata$dog_moves %>%
  replace_na(list(exported = 0, imported = 0)) %>%
  ggplot(aes(state = location, fill = (exported - imported)/total)) +
    geom_statebins() +
    scale_fill_viridis(
     option = "magma", direction = -1
    ) +
    theme_statebins() +
    coord_equal()
```

<img src="{{< blogdown/postref >}}index_files/figure-html/net_exports_std-1.png" width="768" />
