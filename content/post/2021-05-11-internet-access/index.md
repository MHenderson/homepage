---
title: "(WIP) Tidy Tuesday: Internet Access"
author: Matthew Henderson
description: My Tidy Tuesday contribution for 2021, week 20.
date: '2021-05-11'
slug: internet-access
categories:
  - dataviz
tags:
  - tidy-tuesday
draft: yes
editor_options: 
  chunk_output_type: console
---



This week's Tidy Tuesday data comes from two sources,
[Microsoft](https://github.com/microsoft/USBroadbandUsagePercentages)
and
[the FCC](https://www.fcc.gov/document/broadband-deployment-report-digital-divide-narrowing-substantially-0)
by way of
[The Verge](https://www.theverge.com/22418074/broadband-gap-america-map-county-microsoft-data).

This was the first time
I can remember using the
[{tigris}](https://cran.r-project.org/web/packages/tigris/index.html),
a package for downloading geographic data
from the US census bureau.
It makes
plotting roads
and county boundaries
a breeze.

For example,
I can download all
roads in Madison County, Kentucky,
home of world famous Berea College,
and plot them with {ggplot2} like so:


```r
library(ggplot2)
library(tigris)

madison_ky_roads <- roads("KY", "Madison", progress_bar = FALSE)

madison_ky_roads %>%
  ggplot() +
  geom_sf(size = .1, alpha = .8) +
  theme_void()
```

{{<figure src="figure/madison_ky_roads_plot-1.png" alt="A plot of roads in Madison County, Kentucky." caption="Roads of Madison County, Ky." width="600">}}

My final plot
is a comparison between
two different ways
of measuring internet access
in Kentucky.

In the plot below there
are two maps of the
counties of Kentucky.

In the top map
colours correspond
to figures from the FCC
that claim to report
percentage of residents
in a county that have
access to broadband internet.
This data comes from
the end of 2017.

The bottom map
is coloured using
Microsoft's data.

The two plots
differ quite substantially.
The proportion of residents
with access to broadband internet,
according to the first plot
appears to be high all across
the state.
The second plot
seems to suggest that the
actual proportion of people
in counties using the internet
at broadband speed is much
lower,
except perhaps in the vicinity
of cities like Lexington,
Louisville,
Bowling Green
and Cincinnati.

Source code: https://github.com/MHenderson/internet-access

![](https://raw.githubusercontent.com/MHenderson/internet-access/master/internet-access.png)
