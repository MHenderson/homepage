---
title: "(WIP) Tidy Tuesday: Student Loan Debt"
description: "tt_load(2019, week = 48)"
author: Matthew Henderson
date: '2019-11-26'
slug: student-loan-debt
categories:
  - dataviz
tags:
  - tidy-tuesday
draft: TRUE
---



This week's data is from the Department of Education courtesy of Alex Albright.

Data idea comes from Dignity and Debt who is running a contest around data viz for understanding and spreading awareness around Student Loan debt.

There are already some gorgeous plots in the style of DuBois.


```r
library(tidytuesdayR)

tuesdata <- tt_load(2019, week = 48)
#> 
#> 	Downloading file 1 of 1: `loans.csv`
```



```r
library(readr)
library(tidyverse)
library(viridis)

tuesdata$loans %>%
  ggplot(aes( x = quarter, y = total)) +
    geom_point() +
    facet_wrap(~year)
```

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-2-1.png" width="672" />
