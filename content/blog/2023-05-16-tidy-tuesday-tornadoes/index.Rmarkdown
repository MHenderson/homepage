---
title: 'Tidy Tuesday: Tornadoes'
author: Matthew Henderson
date: '2023-05-16'
slug: tidy-tuesday-tornadoes
categories:
  - dataviz
tags:
  - tidy-tuesday
subtitle: ''
excerpt: "Mapping the paths of tornados in Kentucky from 1952 - 2022 with the sf packing in R and data from
  NOAA's National Weather Service Storm Prediction Center Severe Weather Maps, Graphics, and Data Page"
draft: false
series: ~
layout: single
---

This week Tidy Tuesday was all about tornadoes.
Data came from 
[NOAA's National Weather Service Storm Prediction Center Severe Weather Maps, Graphics, and Data Page](https://www.spc.noaa.gov/wcm/).

To draw the maps below I used the {{sf}} package in R.
I used `geom_sf` to plot both the Kentucky state boundary using data from the {{tigris}} package as well as tornado paths from the NOAA data.

The first version I created was too clutterred and hard to interpret.
So I tried again, introducing a decade variable so that I could plot different tornadoes from different decades on different maps with `geom_facet`.

![This image shows a grid of maps of the US state of Kentucky. Each map represents a different decade and is filled with coloured arrows showing the paths of tornadoes in that decade. The arrows are coloured according to the intensity of the tornado. The plot shows that during the 1980s there were relatively few tornadoes in Kentucky while in the 1970s there were a large number of very intense torndoes. In recent decades the number of tornadoes appears to have increased but there are fewer of high intensity.](ky-tornadoes-plot.png)

The final version of this plot originally included county boundaries.
But I decided to remove them as they interfered with the state boundary and made the plot too messy when combined with lots of arrows.
I wish I could have found a way to add the county boundaries in a more subtle way so they could be seen but without affecting the overall simplicity of the final plot.

Although the final plot arguably lacks a compelling story I think it does have the property of allowing the viewer to find something interesting by exploring the plot.

For example, after looking at the plot for a while it became clear to me that during the 1970s there were a large number of powerful tornadoes in Kentucky, particularly in the central region of the state and especially when compared to the 1980s.
In more recent decades it seems that the western part of the state has experienced most tornado activity.

Spending some time on titles, lables and headings improved the plot quite a bit.
I took a little bit of extra care labelling the 1950s and 2020s facets properly as well as finding space to describe the change of scale in 2007 from F to EF.
I used one my favourite themes from the {{hrbrthemes}} package which always improves the overall look of the final result.

This was the first time I used Github Codespaces for an entire project (albeit a very small project).
All of the work I did on this plot was done on Codespaces with the
[rocker/geospatial](https://hub.docker.com/r/rocker/geospatial)
Docker container.

Combining {{renv}} and {{targets}} made things especially easy.
Resuming work inside a fresh Codespace is just a matter of calling `renv::restore()` followed by `targets::tar_make()`.
Package installations are fast thanks to RStudio Package Manager.
