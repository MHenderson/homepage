---
title: "(WIP) Tidy Tuesday: UN Votes"
author: Matthew Henderson
date: '2021-03-23'
slug: un-votes
categories:
  - posts
tags:
  - tidy-tuesday
draft: yes
editor_options: 
  chunk_output_type: console
---




```r
library(tidytuesdayR)

tuesdata <- tt_load(2021, week = 13)
#> 
#> 	Downloading file 1 of 3: `unvotes.csv`
#> 	Downloading file 2 of 3: `roll_calls.csv`
#> 	Downloading file 3 of 3: `issues.csv`
```


```r
library(htmltab)
library(janitor)
library(stringr)
library(tidyverse)

vote_counts <- tuesdata$unvotes %>% group_by(country) %>% count(vote)

capitals_by_latitude <- htmltab("https://en.wikipedia.org/wiki/List_of_national_capitals_by_latitude", which = 2)

capitals_by_latitude <- capitals_by_latitude %>%
  clean_names() %>%
  rename(latitude = latitude_indicates_southern_hemisphere) %>%
  mutate(country = str_trim(country))

counts_with_capital_lats <- vote_counts %>%
  left_join(capitals_by_latitude) %>%
  filter(!is.na(latitude))

counts_with_capital_lats %>%
  head(90) %>%
  ggplot() +
  aes(x = fct_reorder(country, latitude, .fun = 'first'), fill = vote, weight = n) +
  geom_bar(position = "fill") +
  scale_fill_brewer(palette = "Set1") +
  coord_flip() +
  theme_minimal() +
  xlab("") +
  ylab("Proportion of all votes")
```

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-2-1.png" width="672" />
