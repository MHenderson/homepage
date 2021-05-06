---
title: "Tidy Tuesday: Water Sources"
author: Matthew Henderson
date: '2021-05-04'
slug: water-sources
categories:
  - posts
tags:
  - tidy-tuesday
draft: no
editor_options: 
  chunk_output_type: console
---

This week’s Tidy Tuesday data comes from
[Water Point Data Exchange (WPDx)](https://data.waterpointdata.org/dataset/Water-Point-Data-Exchange-WPDx-Basic-/jfkt-jmqa),
a global platform for sharing water point data.

Inspired by David Robinson’s livestream on 4/5/21
I created a faceted map plot
showing the locations of different water sources
throughout Ethiopia.
{{% youtube "5ub92c-5xFQ" %}}

This was my first time
using Thomas Lin Pedersen’s
[{ragg}](https://ragg.r-lib.org/)
package.
It allowed me to use
one of my favourite fonts,
[Cardo.](https://fonts.google.com/specimen/Cardo)

I was also inspired
by the work of
[Georgios Karamanis](https://karaman.is/)
and a tweet
by Nicola Rennie:
{{% tweet "1389614216689164293" %}}

Source code: https://github.com/MHenderson/water-sources

![](https://raw.githubusercontent.com/MHenderson/water-sources/master/water-sources.png)