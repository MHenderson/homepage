---
title: "(WIP) Generating Nonsense with MarkovifyR"
author: Matthew Henderson
date: '2018-01-04'
slug: markovifyr
categories:
  - posts
tags:
  - nlp
  - r
draft: TRUE
---

# MarkovifyR

This post is all about the R package [**markovifyR**](https://github.com/abresler/markovifyR) by
Alex Bresler.

Let’s use Whitman’s *Leaves of Grass* as a starting point.

``` r
library(gutenbergr)

leaves_of_grass <- gutenberg_download(1322, mirror = "http://www.mirrorservice.org/sites/ftp.ibiblio.org/pub/docs/books/gutenberg/")
```

``` r
library(tidyverse)
library(tidytext)

(tidyleaves <- tibble(txt = leaves_of_grass$text) %>%
  unnest_tokens(sentence, txt, token = "sentences"))
#> # A tibble: 14,875 x 1
#>    sentence                                                      
#>    <chr>                                                         
#>  1 leaves of grass                                               
#>  2 by walt whitman                                               
#>  3 come, said my soul,                                           
#>  4 such verses for my body let us write, (for we are one,)       
#>  5 that should i after return,                                   
#>  6 or, long, long hence, in other spheres,                       
#>  7 there to some group of mates the chants resuming,             
#>  8 (tallying earth’s soil, trees, winds, tumultuous waves,)      
#>  9 ever with pleas’d smile i may keep on,                        
#> 10 ever and ever yet the verses owning--as, first, i here and now
#> # … with 14,865 more rows
```

``` r
library(markovifyR)

markov_model <-
  generate_markovify_model(
    input_text = tidyleaves %>% pull(sentence),
    markov_state_size = 2L,
    max_overlap_total = 5,
    max_overlap_ratio = .4
  )
```

``` r
results <- markovify_text(
  markov_model = markov_model,
  maximum_sentence_length = NULL,
  output_column_name = 'waltWhitman',
  count = 5,
  tries = 300,
  only_distinct = TRUE,
  return_message = FALSE
)
```

``` r
library(glue)
library(htmltools)

results %>%
  glue_data("{waltWhitman}") %>%
  glue_collapse(sep = " ") %>%
  tags$p()
```

<p>inures not to me--yet there are no scholar and never be quiet again. we hurt each other the eastern sea and on land. some walk by myself--i stand and lean on the vapor and the vacant lot at sundown for your lives! a frequent sample of the pairing of birds, bustle of instruments, they will do nothing but you, o democracy from asia, from the east and west, and the great trout swimming,</p>
